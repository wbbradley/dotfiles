"""Unit tests for pr_wait.py condition evaluation. No network: run with
    python3 -m unittest discover -s ~/src/dotfiles/bin/tests
"""

import contextlib
import copy
import io
import json
import sys
import unittest
from pathlib import Path
from unittest import mock

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "bin"))

import pr_wait  # noqa: E402
from pr_wait import Baseline, GhError, Options, Snapshot, evaluate, evaluate_run, poll_loop  # noqa: E402

FIXTURES = Path(__file__).parent / "fixtures"


def load(name: str):
    return json.loads((FIXTURES / name).read_text())


def snapshot(**overrides) -> Snapshot:
    """Snapshot of an open PR with pending CI, one old bot review, one old comment."""
    base = dict(
        head="aaaaaaa0000000000000000000000000000000aa",
        state="open",
        merged=False,
        mergeable_state="blocked",
        check_runs=load("check_runs_pending.json")["check_runs"],
        statuses=[],
        reviews=load("reviews.json"),
        issue_comments=load("issue_comments.json"),
        review_comments=load("review_comments.json"),
    )
    base.update(overrides)
    return Snapshot(**copy.deepcopy(base))


class ChecksTests(unittest.TestCase):
    def test_pending_checks_do_not_complete(self):
        snap = snapshot()
        self.assertIsNone(evaluate(snap, Baseline.from_snapshot(snap), Options(checks_complete=True)))

    def test_no_checks_yet_is_not_complete(self):
        snap = snapshot(check_runs=[], statuses=[])
        self.assertIsNone(evaluate(snap, Baseline.from_snapshot(snap), Options(checks_complete=True)))

    def test_all_completed(self):
        snap = snapshot(check_runs=load("check_runs_success.json")["check_runs"])
        out = evaluate(snap, Baseline.from_snapshot(snap), Options(checks_complete=True))
        self.assertEqual(out.event, "checks_complete")
        self.assertEqual(out.code, 0)

    def test_legacy_status_pending_blocks_completion(self):
        snap = snapshot(
            check_runs=load("check_runs_success.json")["check_runs"],
            statuses=[{"context": "ci/legacy", "state": "pending"}],
        )
        self.assertIsNone(evaluate(snap, Baseline.from_snapshot(snap), Options(checks_complete=True)))

    def test_check_failed_is_fail_fast(self):
        snap = snapshot(check_runs=load("check_runs_failed.json")["check_runs"])
        out = evaluate(snap, Baseline.from_snapshot(snap), Options(checks_complete=True, check_failed=True))
        self.assertEqual(out.event, "check_failed")
        self.assertEqual(out.code, 3)
        self.assertIn("lint=failure", out.matched[0].detail)

    def test_superseded_failure_does_not_fire(self):
        """#9214 head 8c1a8a042: 'changelog note' failed, then was re-run twice
        (skipped) after the no-changelog label. Only the newest run counts."""
        snap = snapshot(check_runs=load("check_runs_superseded.json")["check_runs"])
        self.assertIsNone(pr_wait.eval_check_failed(snap))
        m = pr_wait.eval_checks_complete(snap)
        self.assertIsNotNone(m)
        self.assertEqual(m.detail, "2 checks settled")

    def test_same_second_reruns_tiebreak_on_id(self):
        runs = load("check_runs_superseded.json")["check_runs"][:3]  # drop the 21:12:21 run
        snap = snapshot(check_runs=runs)
        # ids 115541961128 (failure) and 115541971447 (skipped) share started_at;
        # the higher id is the later run.
        self.assertIsNone(pr_wait.eval_check_failed(snap))

    def test_newest_run_failing_still_fires(self):
        runs = load("check_runs_superseded.json")["check_runs"]
        runs[-1]["conclusion"] = "failure"
        snap = snapshot(check_runs=runs)
        m = pr_wait.eval_check_failed(snap)
        self.assertIsNotNone(m)
        self.assertEqual(m.detail, "changelog note=failure")

    def test_same_name_from_different_apps_is_not_collapsed(self):
        runs = load("check_runs_superseded.json")["check_runs"]
        other = dict(runs[-1], id=999, app={"id": 1, "slug": "other-ci"}, conclusion="failure")
        snap = snapshot(check_runs=runs + [other])
        m = pr_wait.eval_check_failed(snap)
        self.assertIsNotNone(m)
        self.assertEqual(m.detail, "changelog note=failure")

    def test_pending_rerun_supersedes_completed_run(self):
        runs = load("check_runs_superseded.json")["check_runs"]
        runs[-1].update(status="in_progress", conclusion=None)
        snap = snapshot(check_runs=runs)
        self.assertIsNone(pr_wait.eval_checks_complete(snap))

    def test_failed_check_while_others_pending_still_fires(self):
        runs = load("check_runs_failed.json")["check_runs"]
        runs[0]["status"], runs[0]["conclusion"] = "in_progress", None
        snap = snapshot(check_runs=runs)
        out = evaluate(snap, Baseline.from_snapshot(snap), Options(check_failed=True))
        self.assertEqual(out.code, 3)

    def test_legacy_status_error_counts_as_failed(self):
        snap = snapshot(statuses=[{"context": "ci/legacy", "state": "error"}])
        out = evaluate(snap, Baseline.from_snapshot(snap), Options(check_failed=True))
        self.assertEqual(out.event, "check_failed")


class ReviewTests(unittest.TestCase):
    def test_existing_review_does_not_trigger_without_on_head(self):
        snap = snapshot()
        base = Baseline.from_snapshot(snap)
        self.assertIsNone(evaluate(snap, base, Options(review_by="^neuralwatt-reviews-bot$")))

    def test_new_review_triggers(self):
        snap = snapshot()
        base = Baseline.from_snapshot(snap)
        later = snapshot()
        later.reviews.append(load("review_new_on_head.json"))
        out = evaluate(later, base, Options(review_by="^neuralwatt-reviews-bot$"))
        self.assertEqual(out.event, "review")
        self.assertIn("APPROVED", out.matched[0].detail)

    def test_regex_mismatch_ignored(self):
        snap = snapshot()
        base = Baseline.from_snapshot(snap)
        later = snapshot()
        later.reviews.append(load("review_new_on_head.json"))
        self.assertIsNone(evaluate(later, base, Options(review_by="^someone-else$")))

    def test_pending_review_ignored(self):
        snap = snapshot()
        base = Baseline.from_snapshot(snap)
        later = snapshot()
        r = load("review_new_on_head.json")
        r["state"] = "PENDING"
        later.reviews.append(r)
        self.assertIsNone(evaluate(later, base, Options(review_by="neuralwatt-reviews-bot")))

    def test_on_head_ignores_review_on_old_sha(self):
        # The pre-existing fixture review is on an older commit.
        snap = snapshot()
        base = Baseline.from_snapshot(snap)
        self.assertIsNone(evaluate(snap, base, Options(review_by="neuralwatt-reviews-bot", on_head=True)))

    def test_on_head_accepts_preexisting_review_on_current_head(self):
        snap = snapshot()
        snap.reviews.append(load("review_new_on_head.json"))
        base = Baseline.from_snapshot(snap)  # the review already existed at start
        out = evaluate(snap, base, Options(review_by="neuralwatt-reviews-bot", on_head=True))
        self.assertEqual(out.event, "review")
        self.assertEqual(out.code, 0)

    def test_on_head_head_moved_exits_with_target_changed(self):
        snap = snapshot()
        base = Baseline.from_snapshot(snap)
        later = snapshot(head="bbbbbbb0000000000000000000000000000000bb")
        out = evaluate(later, base, Options(review_by="neuralwatt-reviews-bot", on_head=True))
        self.assertEqual(out.event, "head_changed")
        self.assertEqual(out.code, 4)

    def test_head_changed_requested_exits_zero(self):
        snap = snapshot()
        base = Baseline.from_snapshot(snap)
        later = snapshot(head="bbbbbbb0000000000000000000000000000000bb")
        out = evaluate(later, base, Options(head_changed=True))
        self.assertEqual(out.code, 0)
        self.assertIn("aaaaaaa -> bbbbbbb", out.matched[0].detail)

    def test_head_moved_without_on_head_keeps_waiting(self):
        snap = snapshot()
        base = Baseline.from_snapshot(snap)
        later = snapshot(head="bbbbbbb0000000000000000000000000000000bb")
        self.assertIsNone(evaluate(later, base, Options(review_by="neuralwatt-reviews-bot")))


class CommentTests(unittest.TestCase):
    def _later(self):
        snap = snapshot()
        base = Baseline.from_snapshot(snap)
        return snap, base, snapshot()

    def test_no_new_comments(self):
        snap, base, later = self._later()
        self.assertIsNone(evaluate(later, base, Options(new_comment=True)))

    def test_new_issue_comment(self):
        _, base, later = self._later()
        later.issue_comments.append({"id": 901, "user": {"login": "wbbradley"}, "body": "ship it"})
        out = evaluate(later, base, Options(new_comment=True))
        self.assertEqual(out.matched[0].detail, "issue:wbbradley#901")

    def test_new_inline_comment(self):
        _, base, later = self._later()
        later.review_comments.append({"id": 902, "user": {"login": "wbbradley"}, "body": "nit"})
        out = evaluate(later, base, Options(new_comment=True))
        self.assertEqual(out.matched[0].detail, "inline:wbbradley#902")

    def test_new_review_summary_counts_as_comment(self):
        _, base, later = self._later()
        later.reviews.append(load("review_new_on_head.json"))
        out = evaluate(later, base, Options(new_comment=True))
        self.assertTrue(out.matched[0].detail.startswith("review:neuralwatt-reviews-bot#"))

    def test_review_without_body_is_not_a_comment(self):
        _, base, later = self._later()
        r = load("review_new_on_head.json")
        r["body"] = ""
        later.reviews.append(r)
        self.assertIsNone(evaluate(later, base, Options(new_comment=True)))

    def test_ignore_author(self):
        _, base, later = self._later()
        later.issue_comments.append({"id": 903, "user": {"login": "agent-bot[bot]"}, "body": "reply"})
        self.assertIsNone(evaluate(later, base, Options(new_comment=True, ignore_author=r"^agent-bot")))
        self.assertIsNotNone(evaluate(later, base, Options(new_comment=True, ignore_author=r"^nobody$")))

    def test_ignore_marker(self):
        _, base, later = self._later()
        later.review_comments.append({"id": 904, "user": {"login": "wbbradley"}, "body": "Agent: fixed in abc123"})
        self.assertIsNone(evaluate(later, base, Options(new_comment=True, ignore_marker="Agent")))

    def test_ignored_new_comment_plus_real_one(self):
        _, base, later = self._later()
        later.issue_comments.append({"id": 905, "user": {"login": "me"}, "body": "Agent: done"})
        later.issue_comments.append({"id": 906, "user": {"login": "reviewer"}, "body": "one more thing"})
        out = evaluate(later, base, Options(new_comment=True, ignore_marker="Agent"))
        self.assertEqual(out.matched[0].detail, "issue:reviewer#906")


class StateTests(unittest.TestCase):
    def test_merge_state_case_insensitive(self):
        snap = snapshot(mergeable_state="clean")
        base = Baseline.from_snapshot(snap)
        self.assertIsNone(evaluate(snap, base, Options(merge_state="DIRTY")))
        out = evaluate(snap, base, Options(merge_state="CLEAN"))
        self.assertEqual(out.event, "merge_state")

    def test_pr_closed_requested(self):
        snap = snapshot(state="closed", merged=True)
        out = evaluate(snap, Baseline.from_snapshot(snap), Options(pr_closed=True))
        self.assertEqual((out.event, out.code, out.matched[0].detail), ("pr_closed", 0, "merged"))

    def test_pr_closed_unrequested_is_target_changed(self):
        snap = snapshot(state="closed", merged=False)
        out = evaluate(snap, Baseline.from_snapshot(snap), Options(checks_complete=True))
        self.assertEqual((out.event, out.code, out.matched[0].detail), ("pr_closed", 4, "closed"))


class CombineTests(unittest.TestCase):
    def test_any_default(self):
        snap = snapshot(mergeable_state="clean")  # checks still pending
        out = evaluate(snap, Baseline.from_snapshot(snap), Options(merge_state="clean", checks_complete=True))
        self.assertEqual(out.event, "merge_state")
        self.assertEqual([m.name for m in out.matched], ["merge_state"])

    def test_all_requires_every_condition(self):
        snap = snapshot(mergeable_state="clean")
        opts = Options(merge_state="clean", checks_complete=True, require_all=True)
        self.assertIsNone(evaluate(snap, Baseline.from_snapshot(snap), opts))
        snap.check_runs = load("check_runs_success.json")["check_runs"]
        out = evaluate(snap, Baseline.from_snapshot(snap), opts)
        self.assertEqual(sorted(m.name for m in out.matched), ["checks_complete", "merge_state"])

    def test_all_still_fails_fast_on_check_failure(self):
        # --all with a failed check: check_failed holds, checks_complete holds, so both match.
        snap = snapshot(check_runs=load("check_runs_failed.json")["check_runs"])
        opts = Options(checks_complete=True, check_failed=True, require_all=True)
        out = evaluate(snap, Baseline.from_snapshot(snap), opts)
        self.assertEqual(out.event, "check_failed")
        self.assertEqual(out.code, 3)

    def test_all_exits_on_green_with_check_failed(self):
        # --check-failed is fail-fast, not a conjunct: all-green CI must satisfy --all.
        snap = snapshot(mergeable_state="clean", check_runs=load("check_runs_success.json")["check_runs"])
        opts = Options(merge_state="clean", checks_complete=True, check_failed=True, require_all=True)
        out = evaluate(snap, Baseline.from_snapshot(snap), opts)
        self.assertEqual((out.code, sorted(m.name for m in out.matched)), (0, ["checks_complete", "merge_state"]))

    def test_all_fails_fast_before_other_conjuncts_hold(self):
        # A red check ends the wait even while another --all condition (merge state) doesn't hold.
        snap = snapshot(check_runs=load("check_runs_failed.json")["check_runs"])
        opts = Options(merge_state="clean", checks_complete=True, check_failed=True, require_all=True)
        out = evaluate(snap, Baseline.from_snapshot(snap), opts)
        self.assertEqual((out.event, out.code), ("check_failed", 3))


class RunTests(unittest.TestCase):
    def test_in_progress(self):
        self.assertIsNone(evaluate_run({"status": "in_progress", "conclusion": None}))

    def test_success(self):
        out = evaluate_run({"status": "completed", "conclusion": "success", "name": "CI"})
        self.assertEqual((out.code, out.matched[0].detail), (0, "CI=success"))

    def test_failure(self):
        out = evaluate_run({"status": "completed", "conclusion": "failure", "name": "CI"})
        self.assertEqual(out.code, 3)


class PollLoopTests(unittest.TestCase):
    def _clock(self, step=1.0):
        t = [0.0]

        def clock():
            return t[0]

        def sleep(s):
            t[0] += s

        return clock, sleep

    def test_returns_when_decided(self):
        clock, sleep = self._clock()
        fetches = iter([None, None, "go"])
        outcome, last, code = poll_loop(
            lambda: next(fetches), lambda s: pr_wait.Outcome("x", 0, []) if s else None,
            interval=5, timeout=100, max_errors=3, verbose=False, sleep=sleep, clock=clock,
        )
        self.assertEqual((outcome.event, last, code), ("x", "go", 0))

    def test_timeout(self):
        clock, sleep = self._clock()
        _, _, code = poll_loop(
            lambda: None, lambda s: None,
            interval=30, timeout=100, max_errors=3, verbose=False, sleep=sleep, clock=clock,
        )
        self.assertEqual(code, 2)
        self.assertGreaterEqual(clock(), 100)

    def test_transient_errors_recover(self):
        clock, sleep = self._clock()
        seq = iter([GhError("boom"), GhError("boom"), "ok"])

        def fetch():
            v = next(seq)
            if isinstance(v, Exception):
                raise v
            return v

        outcome, _, code = poll_loop(
            fetch, lambda s: pr_wait.Outcome("x", 0, []),
            interval=1, timeout=100, max_errors=3, verbose=False, sleep=sleep, clock=clock,
        )
        self.assertEqual(code, 0)

    def test_consecutive_errors_give_up(self):
        clock, sleep = self._clock()

        def fetch():
            raise GhError("down")

        outcome, _, code = poll_loop(
            fetch, lambda s: None,
            interval=1, timeout=100, max_errors=3, verbose=False, sleep=sleep, clock=clock,
        )
        self.assertIsNone(outcome)
        self.assertEqual(code, 1)


class CliTests(unittest.TestCase):
    def test_requires_condition(self):
        with self.assertRaises(SystemExit):
            pr_wait.main(["--repo", "o/r", "--pr", "1"])

    def test_bad_regex(self):
        with self.assertRaises(SystemExit):
            pr_wait.main(["--repo", "o/r", "--pr", "1", "--review-by", "("])

    def test_run_rejects_pr_conditions(self):
        with self.assertRaises(SystemExit):
            pr_wait.main(["--repo", "o/r", "--run", "1", "--checks-complete"])

    def test_pr_and_run_exclusive(self):
        with self.assertRaises(SystemExit):
            pr_wait.main(["--repo", "o/r", "--pr", "1", "--run", "2"])


class TimeoutClampTests(unittest.TestCase):
    def run_main(self, *extra):
        """Run a --run wait whose first poll times out; return the poll_loop timeout and JSON."""
        seen = {}

        def fake_poll_loop(fetch, evaluate_fn, *, timeout, **kw):
            seen["timeout"] = timeout
            return None, None, 2

        out, err = io.StringIO(), io.StringIO()
        with mock.patch.object(pr_wait, "poll_loop", fake_poll_loop), \
                contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
            code = pr_wait.main(["--repo", "o/r", "--run", "1", *extra])
        self.assertEqual(code, 2)
        return seen["timeout"], json.loads(out.getvalue()), err.getvalue()

    def test_default_is_the_maximum(self):
        timeout, payload, err = self.run_main()
        self.assertEqual(timeout, pr_wait.MAX_TIMEOUT)
        self.assertNotIn("warning", payload)
        self.assertEqual(err, "")

    def test_smaller_timeout_kept(self):
        timeout, payload, _ = self.run_main("--timeout", "120")
        self.assertEqual(timeout, 120)
        self.assertNotIn("warning", payload)

    def test_larger_timeout_clamped_with_warning(self):
        timeout, payload, err = self.run_main("--timeout", "5400")
        self.assertEqual(timeout, pr_wait.MAX_TIMEOUT)
        self.assertIn("clamped", payload["warning"])
        self.assertIn("clamped", err)
        self.assertEqual(payload["event"], "timeout")


if __name__ == "__main__":
    unittest.main()
