#!/usr/bin/env python3
"""pr_wait.py - block until something interesting happens on a GitHub PR or Actions run.

Polls GitHub via `gh api` (must already be authenticated) and exits the first
time a requested condition is met. Silent while waiting, so a single background
invocation produces exactly one notification. Stdlib only, Python 3.10+.

EXAMPLES
  # Wait for the review bot to review the *current* head, or for a check to fail:
  pr_wait.py --repo neuralwatt/inference_frontend --pr 9231 \\
      --review-by '^neuralwatt-reviews-bot' --on-head --check-failed

  # Wait for CI to settle (either way), fail-fast on the first red check:
  pr_wait.py --repo OWNER/REPO --pr 123 --checks-complete --check-failed

  # Wait for any new human comment, ignoring our own agent replies:
  pr_wait.py --repo OWNER/REPO --pr 123 --new-comment --ignore-marker 'Agent'

  # Require BOTH a clean merge state AND completed checks:
  pr_wait.py --repo OWNER/REPO --pr 123 --merge-state CLEAN --checks-complete --all

  # Wait for a GitHub Actions run to finish:
  pr_wait.py --repo OWNER/REPO --run 123456789

OUTPUT
  Exactly one JSON line on stdout when the command exits, e.g.
    {"event": "review", "pr": 9231, "head": "<sha>", "matched": [...], "elapsed_s": 312.4}
  "event" is the primary reason for exiting; "matched" lists every condition
  that held on the final poll with a short detail per entry.

EXIT CODES
  0  a requested condition was met
  1  usage or unrecoverable error (too many consecutive API failures)
  2  timeout
  3  fail-fast event: --check-failed matched, or an Actions run concluded unsuccessfully
  4  target changed: the PR closed/merged or (with --on-head) the head moved,
     and the corresponding condition was NOT what you asked for

CONDITIONS (repeatable; combined with --any by default)
  --checks-complete   every check-run and legacy commit status on the current
                      head has finished (any conclusion). Not satisfied while the
                      head has zero checks/statuses, to avoid a race right after a push.
  --check-failed      any check-run concluded failure/timed_out/cancelled/action_required,
                      or any legacy status is failure/error. Exit code 3. Always
                      fail-fast: with --all it ends the wait at once and is not
                      one of the conditions that must all hold.
  --review-by REGEX   a review (approve/request-changes/comment) by a login matching
                      REGEX was submitted after this command started. With --on-head,
                      a review is counted only if it is on the current head SHA, and
                      reviews that already existed on that SHA at start count too.
  --new-comment       a new issue comment, inline review comment, or review summary
                      appeared since start, excluding ones whose author matches
                      --ignore-author or whose body contains --ignore-marker.
  --merge-state STATE GitHub mergeable_state equals STATE (CLEAN, DIRTY, BLOCKED,
                      BEHIND, UNSTABLE, UNKNOWN, DRAFT, HAS_HOOKS). Case-insensitive.
  --pr-closed         the PR is merged or closed.
  --head-changed      the head SHA differs from the one seen at start.

The PR closing always ends the wait, and so does the head moving when --on-head
is given, whether or not you asked for those conditions (see exit code 4).
"""

from __future__ import annotations

import argparse
import json
import re
import subprocess
import sys
import time
from dataclasses import dataclass, field
from typing import Any, Callable

FAILED_CONCLUSIONS = {"failure", "timed_out", "cancelled", "action_required"}
FAILED_STATUS_STATES = {"failure", "error"}
RUN_SUCCESS_CONCLUSIONS = {"success", "neutral", "skipped"}


class GhError(RuntimeError):
    """A `gh api` call failed (network, auth, rate limit, 5xx, ...)."""


# --------------------------------------------------------------------------- #
# GitHub access
# --------------------------------------------------------------------------- #


def gh_api(path: str, timeout: float = 60.0) -> Any:
    """Run `gh api PATH` and return the decoded JSON body."""
    try:
        proc = subprocess.run(
            ["gh", "api", path],
            capture_output=True,
            text=True,
            timeout=timeout,
            check=False,
        )
    except (OSError, subprocess.TimeoutExpired) as exc:
        raise GhError(f"gh api {path}: {exc}") from exc
    if proc.returncode != 0:
        raise GhError(f"gh api {path}: exit {proc.returncode}: {proc.stderr.strip()[:500]}")
    try:
        return json.loads(proc.stdout)
    except json.JSONDecodeError as exc:
        raise GhError(f"gh api {path}: bad JSON: {exc}") from exc


def gh_paginate(path: str, key: str | None = None, per_page: int = 100) -> list[Any]:
    """Fetch every page of a list endpoint.

    `key` names the array inside an object response (e.g. "check_runs");
    None means the response body itself is the array.
    """
    sep = "&" if "?" in path else "?"
    items: list[Any] = []
    page = 1
    while True:
        body = gh_api(f"{path}{sep}per_page={per_page}&page={page}")
        chunk = body[key] if key else body
        if not isinstance(chunk, list):
            raise GhError(f"gh api {path}: expected list under {key!r}")
        items.extend(chunk)
        if len(chunk) < per_page:
            return items
        page += 1


# --------------------------------------------------------------------------- #
# Snapshot of PR state (pure data; built from the API or from test fixtures)
# --------------------------------------------------------------------------- #


@dataclass
class Snapshot:
    head: str
    state: str  # "open" | "closed"
    merged: bool
    mergeable_state: str | None
    check_runs: list[dict] = field(default_factory=list)  # on head
    statuses: list[dict] = field(default_factory=list)  # legacy statuses on head
    reviews: list[dict] = field(default_factory=list)
    issue_comments: list[dict] = field(default_factory=list)
    review_comments: list[dict] = field(default_factory=list)

    @property
    def review_summaries(self) -> list[dict]:
        """Reviews with a non-empty body behave like comments for --new-comment."""
        return [r for r in self.reviews if (r.get("body") or "").strip()]


def fetch_snapshot(repo: str, pr: int, need: set[str]) -> Snapshot:
    """Fetch only the endpoints the requested conditions need."""
    p = gh_api(f"repos/{repo}/pulls/{pr}")
    head = p["head"]["sha"]
    snap = Snapshot(
        head=head,
        state=p.get("state", "open"),
        merged=bool(p.get("merged")),
        mergeable_state=p.get("mergeable_state"),
    )
    if need & {"checks", "reviews", "comments"} and snap.state != "open":
        return snap  # closed PRs end the wait regardless; skip the extra calls
    if "checks" in need:
        snap.check_runs = gh_paginate(f"repos/{repo}/commits/{head}/check-runs", key="check_runs")
        snap.statuses = gh_paginate(f"repos/{repo}/commits/{head}/statuses")
    if "reviews" in need or "comments" in need:
        snap.reviews = gh_paginate(f"repos/{repo}/pulls/{pr}/reviews")
    if "comments" in need:
        snap.issue_comments = gh_paginate(f"repos/{repo}/issues/{pr}/comments")
        snap.review_comments = gh_paginate(f"repos/{repo}/pulls/{pr}/comments")
    return snap


# --------------------------------------------------------------------------- #
# Condition evaluation (pure functions; unit tested against fixtures)
# --------------------------------------------------------------------------- #


@dataclass
class Baseline:
    """What existed when the command started; used to detect *new* things."""

    head: str
    review_ids: set[int]
    issue_comment_ids: set[int]
    review_comment_ids: set[int]
    review_summary_ids: set[int]

    @classmethod
    def from_snapshot(cls, snap: Snapshot) -> "Baseline":
        return cls(
            head=snap.head,
            review_ids={r["id"] for r in snap.reviews},
            issue_comment_ids={c["id"] for c in snap.issue_comments},
            review_comment_ids={c["id"] for c in snap.review_comments},
            review_summary_ids={r["id"] for r in snap.review_summaries},
        )


@dataclass
class Options:
    checks_complete: bool = False
    check_failed: bool = False
    review_by: str | None = None
    on_head: bool = False
    new_comment: bool = False
    merge_state: str | None = None
    pr_closed: bool = False
    head_changed: bool = False
    ignore_author: str | None = None
    ignore_marker: str | None = None
    require_all: bool = False

    def requested(self) -> list[str]:
        names = []
        if self.checks_complete:
            names.append("checks_complete")
        if self.check_failed:
            names.append("check_failed")
        if self.review_by is not None:
            names.append("review")
        if self.new_comment:
            names.append("new_comment")
        if self.merge_state is not None:
            names.append("merge_state")
        if self.pr_closed:
            names.append("pr_closed")
        if self.head_changed:
            names.append("head_changed")
        return names

    def needs(self) -> set[str]:
        need: set[str] = set()
        if self.checks_complete or self.check_failed:
            need.add("checks")
        if self.review_by is not None:
            need.add("reviews")
        if self.new_comment:
            need.add("comments")
        return need


@dataclass
class Match:
    name: str
    detail: str

    def as_dict(self) -> dict:
        return {"condition": self.name, "detail": self.detail}


def _author(item: dict) -> str:
    return (item.get("user") or {}).get("login") or ""


def latest_check_runs(runs: list[dict]) -> list[dict]:
    """Keep only the most recent run per (app, name).

    A check can run more than once on the same head: a workflow re-triggered
    by a label change, or a manual re-run, lands as a new check run in a new
    check suite while the old one stays listed. The old run's conclusion is
    stale (the "changelog note" check fails, then is skipped once the
    no-changelog label is added), so only the newest run counts. Newest is by
    started_at, then id: runs started in the same second get distinct ids in
    creation order.
    """
    best: dict[tuple, dict] = {}
    for r in runs:
        app = r.get("app") or {}
        key = (app.get("slug") or app.get("id"), r.get("name"))
        rank = (r.get("started_at") or "", r.get("id") or 0)
        cur = best.get(key)
        if cur is None or rank > cur[0]:
            best[key] = (rank, r)
    return [r for _, r in best.values()]


def eval_checks_complete(snap: Snapshot) -> Match | None:
    runs = latest_check_runs(snap.check_runs)
    if not runs and not snap.statuses:
        return None
    pending_runs = [r["name"] for r in runs if r.get("status") != "completed"]
    pending_statuses = [s["context"] for s in snap.statuses if s.get("state") == "pending"]
    if pending_runs or pending_statuses:
        return None
    n = len(runs) + len(snap.statuses)
    return Match("checks_complete", f"{n} checks settled")


def eval_check_failed(snap: Snapshot) -> Match | None:
    failed = [
        f"{r['name']}={r.get('conclusion')}"
        for r in latest_check_runs(snap.check_runs)
        if r.get("status") == "completed" and r.get("conclusion") in FAILED_CONCLUSIONS
    ]
    failed += [
        f"{s['context']}={s.get('state')}"
        for s in snap.statuses
        if s.get("state") in FAILED_STATUS_STATES
    ]
    if not failed:
        return None
    return Match("check_failed", ", ".join(failed))


def eval_review(snap: Snapshot, base: Baseline, opts: Options) -> Match | None:
    pat = re.compile(opts.review_by or "")
    hits = []
    for r in snap.reviews:
        if r.get("state") == "PENDING" or not pat.search(_author(r)):
            continue
        if opts.on_head:
            if r.get("commit_id") != snap.head:
                continue
        elif r["id"] in base.review_ids:
            continue
        hits.append(f"{_author(r)}:{r.get('state')}@{(r.get('commit_id') or '')[:7]}")
    if not hits:
        return None
    return Match("review", ", ".join(hits))


def _ignored(item: dict, opts: Options) -> bool:
    if opts.ignore_author and re.search(opts.ignore_author, _author(item)):
        return True
    if opts.ignore_marker and opts.ignore_marker in (item.get("body") or ""):
        return True
    return False


def eval_new_comment(snap: Snapshot, base: Baseline, opts: Options) -> Match | None:
    sources = [
        ("issue", snap.issue_comments, base.issue_comment_ids),
        ("inline", snap.review_comments, base.review_comment_ids),
        ("review", snap.review_summaries, base.review_summary_ids),
    ]
    hits = []
    for kind, items, seen in sources:
        for c in items:
            if c["id"] in seen or _ignored(c, opts):
                continue
            hits.append(f"{kind}:{_author(c)}#{c['id']}")
    if not hits:
        return None
    return Match("new_comment", ", ".join(hits))


def eval_merge_state(snap: Snapshot, opts: Options) -> Match | None:
    want = (opts.merge_state or "").lower()
    have = (snap.mergeable_state or "").lower()
    if want and have == want:
        return Match("merge_state", have)
    return None


def eval_pr_closed(snap: Snapshot) -> Match | None:
    if snap.state == "closed":
        return Match("pr_closed", "merged" if snap.merged else "closed")
    return None


def eval_head_changed(snap: Snapshot, base: Baseline) -> Match | None:
    if snap.head != base.head:
        return Match("head_changed", f"{base.head[:7]} -> {snap.head[:7]}")
    return None


@dataclass
class Outcome:
    event: str
    code: int
    matched: list[Match]


def evaluate(snap: Snapshot, base: Baseline, opts: Options) -> Outcome | None:
    """Decide whether to stop. Returns None to keep waiting."""
    requested = set(opts.requested())
    evals: dict[str, Callable[[], Match | None]] = {
        "checks_complete": lambda: eval_checks_complete(snap),
        "check_failed": lambda: eval_check_failed(snap),
        "review": lambda: eval_review(snap, base, opts),
        "new_comment": lambda: eval_new_comment(snap, base, opts),
        "merge_state": lambda: eval_merge_state(snap, opts),
        "pr_closed": lambda: eval_pr_closed(snap),
        "head_changed": lambda: eval_head_changed(snap, base),
    }

    # Unconditional early exits: the thing we were watching no longer exists.
    closed = eval_pr_closed(snap)
    if closed and "pr_closed" not in requested:
        return Outcome("pr_closed", 4, [closed])
    moved = eval_head_changed(snap, base)
    if moved and opts.on_head and "head_changed" not in requested:
        return Outcome("head_changed", 4, [moved])

    matched = [m for name in requested if (m := evals[name]())]
    if not matched:
        return None
    # --check-failed is fail-fast, never one of the --all conjuncts: a red check
    # ends the wait at once, and green CI must not leave --all waiting on it.
    conjuncts = [name for name in requested if name != "check_failed"] or requested
    if opts.require_all and not any(m.name == "check_failed" for m in matched) and \
            not all(any(m.name == name for m in matched) for name in conjuncts):
        return None
    # Fail-fast takes precedence as the headline event.
    primary = next((m for m in matched if m.name == "check_failed"), matched[0])
    matched.sort(key=lambda m: m is not primary)  # headline event first
    return Outcome(primary.name, 3 if primary.name == "check_failed" else 0, matched)


def evaluate_run(run: dict) -> Outcome | None:
    if run.get("status") != "completed":
        return None
    conclusion = run.get("conclusion") or "unknown"
    m = Match("run_complete", f"{run.get('name', 'run')}={conclusion}")
    return Outcome("run_complete", 0 if conclusion in RUN_SUCCESS_CONCLUSIONS else 3, [m])


# --------------------------------------------------------------------------- #
# Main loop
# --------------------------------------------------------------------------- #


def log(verbose: bool, msg: str) -> None:
    if verbose:
        print(f"[pr_wait {time.strftime('%H:%M:%S')}] {msg}", file=sys.stderr, flush=True)


MAX_TIMEOUT = 1800.0


def emit(payload: dict) -> None:
    print(json.dumps(payload, separators=(",", ":")), flush=True)


def poll_loop(
    fetch: Callable[[], Any],
    decide: Callable[[Any], Outcome | None],
    *,
    interval: float,
    timeout: float,
    max_errors: int,
    verbose: bool,
    sleep: Callable[[float], None] = time.sleep,
    clock: Callable[[], float] = time.monotonic,
) -> tuple[Outcome | None, Any, int]:
    """Generic poll loop. Returns (outcome, last_snapshot, exit_code)."""
    start = clock()
    errors = 0
    last: Any = None
    while True:
        try:
            last = fetch()
            errors = 0
        except GhError as exc:
            errors += 1
            log(verbose, f"API error {errors}/{max_errors}: {exc}")
            if errors >= max_errors:
                return None, last, 1
        else:
            outcome = decide(last)
            if outcome:
                return outcome, last, outcome.code
            log(verbose, "no change")
        remaining = timeout - (clock() - start)
        if remaining <= 0:
            return None, last, 2
        sleep(min(interval, remaining))


def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="pr_wait.py",
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    p.add_argument("--repo", required=True, help="OWNER/NAME, e.g. neuralwatt/inference_frontend")
    target = p.add_mutually_exclusive_group(required=True)
    target.add_argument("--pr", type=int, help="pull request number to watch")
    target.add_argument("--run", type=int, help="GitHub Actions run id to wait for (no PR conditions)")

    c = p.add_argument_group("conditions (PR mode)")
    c.add_argument("--checks-complete", action="store_true")
    c.add_argument("--check-failed", action="store_true")
    c.add_argument("--review-by", metavar="REGEX")
    c.add_argument("--on-head", action="store_true", help="only count reviews on the current head; exit if head moves")
    c.add_argument("--new-comment", action="store_true")
    c.add_argument("--merge-state", metavar="STATE")
    c.add_argument("--pr-closed", action="store_true")
    c.add_argument("--head-changed", action="store_true")

    m = p.add_argument_group("modifiers")
    combine = m.add_mutually_exclusive_group()
    combine.add_argument("--any", action="store_true", help="exit when any condition holds (default)")
    combine.add_argument("--all", action="store_true", help="exit only when all conditions hold at once")
    m.add_argument("--ignore-author", metavar="REGEX", help="--new-comment: skip comments by matching logins")
    m.add_argument("--ignore-marker", metavar="TEXT", help="--new-comment: skip comments whose body contains TEXT")
    m.add_argument("--interval", type=float, default=60, help="seconds between polls (default 60)")
    m.add_argument("--timeout", type=float, default=MAX_TIMEOUT,
                   help=f"give up after this many seconds (default and maximum {MAX_TIMEOUT:g}; larger values are clamped)")
    m.add_argument("--max-errors", type=int, default=5, help="consecutive API failures before exit 1 (default 5)")
    m.add_argument("--verbose", action="store_true", help="log each poll to stderr")
    return p


def options_from_args(args: argparse.Namespace) -> Options:
    return Options(
        checks_complete=args.checks_complete,
        check_failed=args.check_failed,
        review_by=args.review_by,
        on_head=args.on_head,
        new_comment=args.new_comment,
        merge_state=args.merge_state,
        pr_closed=args.pr_closed,
        head_changed=args.head_changed,
        ignore_author=args.ignore_author,
        ignore_marker=args.ignore_marker,
        require_all=args.all,
    )


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    started = time.monotonic()
    extra: dict = {}
    if args.timeout > MAX_TIMEOUT:
        extra["warning"] = f"--timeout {args.timeout:g} clamped to the {MAX_TIMEOUT:g}s maximum"
        print(f"pr_wait: warning: {extra['warning']}", file=sys.stderr, flush=True)
        args.timeout = MAX_TIMEOUT

    if args.run is not None:
        if any([args.checks_complete, args.check_failed, args.review_by, args.new_comment,
                args.merge_state, args.pr_closed, args.head_changed]):
            parser.error("--run does not accept PR conditions")
        outcome, run, code = poll_loop(
            lambda: gh_api(f"repos/{args.repo}/actions/runs/{args.run}"),
            evaluate_run,
            interval=args.interval, timeout=args.timeout,
            max_errors=args.max_errors, verbose=args.verbose,
        )
        emit({
            "event": outcome.event if outcome else ("timeout" if code == 2 else "error"),
            "run": args.run,
            "head": (run or {}).get("head_sha"),
            "status": (run or {}).get("status"),
            "conclusion": (run or {}).get("conclusion"),
            "matched": [m.as_dict() for m in (outcome.matched if outcome else [])],
            "elapsed_s": round(time.monotonic() - started, 1), **extra,
        })
        return code

    opts = options_from_args(args)
    if not opts.requested():
        parser.error("give at least one condition (e.g. --checks-complete)")
    for name, pat in (("--review-by", opts.review_by), ("--ignore-author", opts.ignore_author)):
        if pat is not None:
            try:
                re.compile(pat)
            except re.error as exc:
                parser.error(f"{name}: bad regex: {exc}")
    if opts.on_head and opts.review_by is None:
        parser.error("--on-head only makes sense with --review-by")

    need = opts.needs()
    fetch = lambda: fetch_snapshot(args.repo, args.pr, need)  # noqa: E731

    # Baseline poll: establishes head SHA and the set of pre-existing reviews/comments.
    base: Baseline | None = None
    errors = 0
    while base is None:
        try:
            base = Baseline.from_snapshot(fetch())
        except GhError as exc:
            errors += 1
            log(args.verbose, f"baseline API error {errors}/{args.max_errors}: {exc}")
            if errors >= args.max_errors:
                emit({"event": "error", "pr": args.pr, "head": None, "matched": [],
                      "error": str(exc), "elapsed_s": round(time.monotonic() - started, 1), **extra})
                return 1
            time.sleep(min(args.interval, 10))
    log(args.verbose, f"baseline head={base.head[:7]} waiting for {opts.requested()}"
                      f" ({'all' if opts.require_all else 'any'})")

    outcome, snap, code = poll_loop(
        fetch,
        lambda s: evaluate(s, base, opts),
        interval=args.interval, timeout=args.timeout,
        max_errors=args.max_errors, verbose=args.verbose,
    )
    emit({
        "event": outcome.event if outcome else ("timeout" if code == 2 else "error"),
        "pr": args.pr,
        "head": snap.head if snap else base.head,
        "matched": [m.as_dict() for m in (outcome.matched if outcome else [])],
        "elapsed_s": round(time.monotonic() - started, 1), **extra,
    })
    return code


if __name__ == "__main__":
    sys.exit(main())
