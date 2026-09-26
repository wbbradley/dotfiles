"""Exercise upd's progress UI without updating real checkouts or installations."""
import contextlib
import importlib.machinery
import importlib.util
import io
import os
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[1] / "bin/bin/upd"


def load_upd():
    loader = importlib.machinery.SourceFileLoader("upd", str(SCRIPT))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


class Terminal(io.StringIO):
    def isatty(self):
        return True


class ProgressTest(unittest.TestCase):
    def setUp(self):
        self.upd = load_upd()

    def test_parallel_output_is_quiet_and_failure_sections_are_isolated(self):
        upd = self.upd
        output = io.StringIO()
        with tempfile.TemporaryDirectory() as directory, contextlib.redirect_stdout(output):
            root = Path(directory)
            good, bad = root / "good", root / "bad"
            good.mkdir()
            bad.mkdir()
            with upd.Progress("Installations", ["install:good", "install:bad"]):
                with upd.ThreadPoolExecutor(max_workers=2) as pool:
                    futures = [pool.submit(
                        upd.run_job, "install:" + path.name, upd.install_job,
                        path, [sys.executable, "-c", code], "", 0, False, True,
                    ) for path, code in [
                        (good, "print('successful build details')"),
                        (bad, "import sys; print('compiler diagnostic', file=sys.stderr); sys.exit(7)"),
                    ]]
                    for future in futures:
                        future.result()
            before_summary = output.getvalue()
            self.assertNotIn("compiler diagnostic", before_summary)
            self.assertNotIn("successful build details", before_summary)
            self.assertEqual(upd.failure_summary(), 1)
        summary = output.getvalue()[len(before_summary):]
        self.assertIn("install:bad: FAIL", summary)
        self.assertIn("compiler diagnostic", summary)
        self.assertNotIn("successful build details", summary)
        self.assertEqual(upd._status["install:good"], "OK")

    def test_missing_executable_becomes_failure(self):
        upd = self.upd
        with contextlib.redirect_stdout(io.StringIO()):
            with upd.Progress("Test", ["missing"]):
                upd.run_job("missing", upd.stream, "missing", "", 0,
                            ["/nonexistent-upd-test-command"])
            self.assertEqual(upd.failure_summary(), 1)
        self.assertEqual(upd._status["missing"], "FAIL (exception)")
        self.assertIn("FileNotFoundError", "\n".join(upd._logs["missing"]))

    def test_terminal_cleanup_and_clipping_on_exception(self):
        upd = self.upd
        terminal = Terminal()
        with contextlib.redirect_stdout(terminal), patch.dict(os.environ, {"TERM": "xterm"}), \
                patch.object(upd.shutil, "get_terminal_size", return_value=os.terminal_size((42, 8))):
            with self.assertRaises(RuntimeError):
                with upd.Progress("Test", ["build"]) as display:
                    display.start("build")
                    upd.emit("build", "", 0, "\033[31m" + "界" * 100 + "\033[0m\rnext\x00")
                    display.render()
                    raise RuntimeError("interrupted")
        value = terminal.getvalue()
        self.assertIn("\033[?25l", value)
        self.assertTrue(value.endswith("\033[?25h"))
        self.assertIsNone(upd._display)
        self.assertNotIn("\x00", value)
        for line in value.splitlines():
            clean = upd.plain_text(line)
            cells = sum(2 if upd.unicodedata.east_asian_width(c) in "WF" else 1 for c in clean)
            self.assertLessEqual(cells, 41)

    def test_small_terminal_prioritizes_active_jobs(self):
        upd = self.upd
        terminal = Terminal()
        with contextlib.redirect_stdout(terminal), patch.dict(os.environ, {"TERM": "xterm"}), \
                patch.object(upd.shutil, "get_terminal_size", return_value=os.terminal_size((80, 7))):
            with upd.Progress("Test", ["done", "active", "queued", "extra"]) as display:
                display.start("active")
                display.render()
                value = terminal.getvalue()
                self.assertIn("active", value)
                self.assertIn("2 more jobs", value)
                self.assertNotIn("extra", value)
        # The final snapshot still includes every job.
        self.assertIn("extra", terminal.getvalue())

    def test_completed_rows_are_not_redrawn(self):
        upd = self.upd
        terminal = Terminal()
        with contextlib.redirect_stdout(terminal), patch.dict(os.environ, {"TERM": "xterm"}):
            with upd.Progress("Test", ["done", "active"]) as display:
                display.start("done")
                upd.set_status("done", "OK")
                display.finish("done")
                display.start("active")
                display.render()
                offset = terminal.tell()
                display.render()
                delta = terminal.getvalue()[offset:]
                self.assertIn("active", delta)
                self.assertNotIn("done", delta)

    def test_logs_are_bounded_and_control_sequences_removed(self):
        upd = self.upd
        with contextlib.redirect_stdout(io.StringIO()):
            with upd.Progress("Test", ["job"]):
                for i in range(100):
                    upd.emit("job", "", 0, f"\033]0;title\x07\033[31mline {i}\033[0m")
        self.assertEqual(len(upd._logs["job"]), 80)
        self.assertEqual(upd._logs["job"][0], "line 20")
        self.assertEqual(upd._logs["job"][-1], "line 99")

    def test_tree_sitter_failure_affects_exit_status(self):
        upd = self.upd
        with patch.object(sys, "argv", [str(SCRIPT), "--skip-self-update"]), \
                patch.object(upd, "REPOS", {}), \
                patch.object(upd, "sync_password_store"), \
                patch.object(upd, "stream", return_value=23), \
                contextlib.redirect_stdout(io.StringIO()) as output:
            self.assertEqual(upd.main(), 1)
        self.assertIn("install:tree-sitter-cli: FAIL (exit 23)", output.getvalue())
        self.assertNotIn("\033", output.getvalue())



if __name__ == "__main__":
    unittest.main()
