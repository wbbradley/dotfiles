"""Exercise opener dispatch without launching a real browser."""

import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import tempfile
import time
import unittest


BIN = Path(__file__).resolve().parents[1] / "bin/bin"
FAKE_OPENER = """#!/usr/bin/env python3
import json
import os
from pathlib import Path
import subprocess
import sys
import time
root = Path(os.environ["OPEN_TEST_DIR"])
name = Path(sys.argv[0]).name
(root / (name + ".pid")).write_text(str(os.getpid()))
(root / (name + ".args")).write_text(json.dumps(sys.argv[1:]))
mode = os.environ.get("OPEN_TEST_" + name.upper().replace("-", "_"), "success")
if mode == "hang":
    child = subprocess.Popen([sys.executable, "-c", "import time; time.sleep(30)"])
    (root / (name + ".child")).write_text(str(child.pid))
    time.sleep(30)
if mode == "fail":
    sys.exit(1)
"""


class OpenOnMacTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="remote-open-test-")
        self.root = Path(self.directory.name)
        self.bin = self.root / "bin"
        self.bin.mkdir()
        for name in ("open-on-mac", "xdg-open", "open"):
            shutil.copy2(BIN / name, self.bin / name)
        for name in ("ssh", "xdg-open-local"):
            self.fake(name)
        config = self.root / "config"
        config.mkdir()
        (config / "remote-mac-host").write_text("mac.example.test\n")
        self.env = dict(
            os.environ,
            OPEN_TEST_DIR=str(self.root),
            XDG_CONFIG_HOME=str(config),
            PATH=str(self.bin) + os.pathsep + os.environ["PATH"],
        )

    def fake(self, name):
        command = self.bin / name
        command.write_text(FAKE_OPENER)
        command.chmod(0o755)

    def tearDown(self):
        for marker in self.root.glob("*.pid"):
            try:
                os.killpg(int(marker.read_text()), signal.SIGKILL)
            except ProcessLookupError:
                pass
        self.directory.cleanup()

    def dispatch(self, command, *args):
        started = time.monotonic()
        result = subprocess.run(
            [str(command), *args], env=self.env, capture_output=True, timeout=2
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, b"")
        self.assertEqual(result.stderr, b"")
        self.assertLess(time.monotonic() - started, 0.5)

    def arguments(self, name):
        deadline = time.monotonic() + 3
        while time.monotonic() < deadline:
            try:
                return json.loads((self.root / (name + ".args")).read_text())
            except (FileNotFoundError, json.JSONDecodeError):
                time.sleep(0.01)
        self.fail(name + " did not run")

    def test_helper_requires_an_explicit_host(self):
        result = subprocess.run(
            [str(self.bin / "open-on-mac"), "https://example.org/"],
            env=self.env,
            capture_output=True,
            timeout=2,
        )
        self.assertEqual(result.returncode, 2)
        self.assertIn(b"--host", result.stderr)
        self.assertFalse((self.root / "ssh.args").exists())

    def test_unconfigured_wrapper_opens_locally(self):
        (self.root / "config/remote-mac-host").unlink()
        self.fake("open-on-mac")
        self.dispatch(self.bin / "xdg-open", "https://example.org/")
        self.assertEqual(self.arguments("xdg-open-local"), ["https://example.org/"])
        self.assertFalse((self.root / "open-on-mac.args").exists())

    def test_host_file_does_not_require_a_trailing_newline(self):
        (self.root / "config/remote-mac-host").write_text("mac.example.test")
        self.fake("open-on-mac")
        self.dispatch(self.bin / "xdg-open", "https://example.org/")
        self.assertEqual(
            self.arguments("open-on-mac"),
            ["--host", "mac.example.test", "https://example.org/"],
        )

    def test_remote_success_and_shell_quoting(self):
        import shlex

        url = 'https://example.org/a\'b?x=$(touch BAD)&quoted="two words"'
        self.dispatch(self.bin / "open-on-mac", "--host", "mac.example.test", url)
        args = self.arguments("ssh")
        self.assertEqual(args[-2], "mac.example.test")
        self.assertEqual(shlex.split(args[-1]), ["/usr/bin/open", "-u", url])
        self.assertIn("BatchMode=yes", args)
        self.assertIn("StrictHostKeyChecking=yes", args)
        time.sleep(0.1)
        self.assertFalse((self.root / "xdg-open-local.args").exists())

    def test_failure_uses_local_fallback(self):
        self.env["OPEN_TEST_SSH"] = "fail"
        url = "https://example.org/?a=1&b=two words"
        self.dispatch(self.bin / "open-on-mac", "--host", "mac.example.test", url)
        self.assertEqual(self.arguments("xdg-open-local"), [url])

    def test_remote_timeout_kills_descendants_and_falls_back(self):
        self.env["OPEN_TEST_SSH"] = "hang"
        url = "https://example.org/timeout"
        started = time.monotonic()
        self.dispatch(self.bin / "open-on-mac", "--host", "mac.example.test", url)
        self.assertEqual(self.arguments("xdg-open-local"), [url])
        self.assertLess(time.monotonic() - started, 1.5)
        self.assert_stopped("ssh")

    def assert_stopped(self, name):
        for suffix in ("pid", "child"):
            pid = (self.root / (name + "." + suffix)).read_text()
            status = Path("/proc") / pid / "stat"
            if status.exists():
                self.assertEqual(status.read_text().split(") ", 1)[1][0], "Z")

    def test_local_timeout_is_bounded(self):
        self.env["OPEN_TEST_SSH"] = "fail"
        self.env["OPEN_TEST_XDG_OPEN_LOCAL"] = "hang"
        self.dispatch(
            self.bin / "open-on-mac",
            "--host",
            "mac.example.test",
            "https://example.org/",
        )
        self.arguments("xdg-open-local")
        time.sleep(1.1)
        self.assert_stopped("xdg-open-local")

    def test_files_and_other_schemes_stay_local(self):
        self.dispatch(
            self.bin / "open-on-mac",
            "--host",
            "mac.example.test",
            "mailto:person@example.org",
        )
        self.assertEqual(
            self.arguments("xdg-open-local"), ["mailto:person@example.org"]
        )
        self.assertFalse((self.root / "ssh.args").exists())

    def test_xdg_open_symlink_and_open_command_use_remote_helper(self):
        self.fake("open-on-mac")
        link = self.root / "xdg-open"
        link.symlink_to(self.bin / "xdg-open")
        for command in (link, self.bin / "open"):
            self.dispatch(command, "HTTPS://example.org/")
            self.assertEqual(
                self.arguments("open-on-mac"),
                ["--host", "mac.example.test", "HTTPS://example.org/"],
            )
            (self.root / "open-on-mac.args").unlink()

    def test_xdg_open_passes_files_options_and_multiple_arguments_locally(self):
        self.fake("open-on-mac")
        for args in (["/tmp/file with spaces"], ["--help"], ["one", "two"]):
            self.dispatch(self.bin / "xdg-open", *args)
            self.assertEqual(self.arguments("xdg-open-local"), args)
            (self.root / "xdg-open-local.args").unlink()
        self.assertFalse((self.root / "open-on-mac.args").exists())

    def test_local_fallback_retains_gtk_focus_launch(self):
        shutil.copy2(BIN / "xdg-open-local", self.bin / "xdg-open-local")
        self.fake("gtk-launch")
        mime = self.bin / "xdg-mime"
        mime.write_text("#!/bin/sh\nprintf '%s\\n' google-chrome.desktop\n")
        mime.chmod(0o755)
        url = "https://example.org/?one=1&two=2"
        self.dispatch(self.bin / "xdg-open-local", url)
        self.assertEqual(self.arguments("gtk-launch"), ["google-chrome.desktop", url])


if __name__ == "__main__":
    unittest.main()
