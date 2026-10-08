"""Check byte delivery and deadlines without touching either real clipboard."""

import json
import os
from pathlib import Path
import signal
import subprocess
import tempfile
import time
import unittest


HELPER = Path(__file__).resolve().parents[1] / "bin/bin/tmux-copy-mac"
FAKE_COPY = '''#!/usr/bin/env python3
import json
import os
from pathlib import Path
import subprocess
import sys
import time

root = Path(os.environ["COPY_TEST_DIR"])
name = Path(sys.argv[0]).name
(root / (name + ".args")).write_text(json.dumps(sys.argv[1:]))
(root / (name + ".pid")).write_text(str(os.getpid()))
mode = os.environ.get("COPY_TEST_" + name.upper(), "success")
if mode == "fail":
    sys.exit(1)
if mode == "hang":
    child = subprocess.Popen([sys.executable, "-c", "import time; time.sleep(30)"])
    (root / (name + ".child")).write_text(str(child.pid))
    time.sleep(30)
(root / (name + ".bytes")).write_bytes(sys.stdin.buffer.read())
'''


class TmuxCopyMacTest(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory(prefix="tmux-copy-test-")
        self.root = Path(self.directory.name)
        for command in ("ssh", "xclip"):
            executable = self.root / command
            executable.write_text(FAKE_COPY)
            executable.chmod(0o755)
        self.env = dict(
            os.environ,
            COPY_TEST_DIR=str(self.root),
            PATH=str(self.root) + os.pathsep + os.environ["PATH"],
        )

    def tearDown(self):
        # Clean up even if a deadline regression causes the test to fail.
        for path in self.root.glob("*.pid"):
            try:
                os.killpg(int(path.read_text()), signal.SIGKILL)
            except ProcessLookupError:
                pass
        self.directory.cleanup()

    def copy(self, contents, *args):
        start = time.monotonic()
        result = subprocess.run(
            [str(HELPER), *args], input=contents, capture_output=True,
            env=self.env, timeout=3,
        )
        self.assertEqual(result.returncode, 0)
        self.assertEqual(result.stdout, b"")
        self.assertEqual(result.stderr, b"")
        self.assertLess(time.monotonic() - start, 2)

    def assert_stopped(self, name):
        for suffix in ("pid", "child"):
            pid = (self.root / (name + "." + suffix)).read_text()
            status = Path("/proc") / pid / "stat"
            if status.exists():
                # An orphan awaiting reaping is dead, though its PID still exists.
                self.assertEqual(status.read_text().split(") ", 1)[1][0], "Z")

    def test_exact_bytes_and_destination(self):
        contents = "Unicode: λ 🍂\n".encode() + b"NUL: \0\n\n"
        self.copy(contents)
        for name in ("ssh", "xclip"):
            self.assertEqual((self.root / (name + ".bytes")).read_bytes(), contents)
        args = json.loads((self.root / "ssh.args").read_text())
        self.assertEqual(args[-2:], ["obsidian", "/usr/bin/pbcopy"])
        self.assertIn("BatchMode=yes", args)
        self.assertIn("StrictHostKeyChecking=yes", args)

    def test_host_override(self):
        self.copy(b"selection", "other-mac")
        args = json.loads((self.root / "ssh.args").read_text())
        self.assertEqual(args[-2], "other-mac")

    def test_stalled_ssh_preserves_local_copy_and_kills_descendants(self):
        self.env["COPY_TEST_SSH"] = "hang"
        # Exceed pipe capacity to also exercise timeout while writing to SSH.
        contents = b"selected text\n" * 20000
        self.copy(contents)
        self.assertEqual((self.root / "xclip.bytes").read_bytes(), contents)
        self.assert_stopped("ssh")

    def test_failed_ssh_preserves_local_copy(self):
        self.env["COPY_TEST_SSH"] = "fail"
        self.copy(b"local copy")
        self.assertEqual((self.root / "xclip.bytes").read_bytes(), b"local copy")

    def test_failed_local_copy_preserves_remote_copy(self):
        self.env["COPY_TEST_XCLIP"] = "fail"
        self.copy(b"remote copy")
        self.assertEqual((self.root / "ssh.bytes").read_bytes(), b"remote copy")

    def test_stalled_local_copy_preserves_remote_copy(self):
        self.env["COPY_TEST_XCLIP"] = "hang"
        self.copy(b"remote copy")
        self.assertEqual((self.root / "ssh.bytes").read_bytes(), b"remote copy")
        self.assert_stopped("xclip")

    def test_stalled_input_stops_before_launching_commands(self):
        process = subprocess.Popen(
            [str(HELPER)], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
            stderr=subprocess.PIPE, env=self.env,
        )
        try:
            process.wait(timeout=2)
            self.assertEqual(process.returncode, 0)
            self.assertEqual(process.communicate(), (b"", b""))
            self.assertFalse((self.root / "ssh.args").exists())
            self.assertFalse((self.root / "xclip.args").exists())
        finally:
            if process.poll() is None:
                process.kill()
            process.communicate()


if __name__ == "__main__":
    unittest.main()
