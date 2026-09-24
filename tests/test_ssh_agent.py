"""Exercise the Bash helper with real agents, without touching personal SSH state."""
import os
from pathlib import Path
import re
import signal
import socket
import subprocess
import tempfile
import time
import unittest


class SharedAgentTest(unittest.TestCase):
    def test_shared_agent(self):
        bashrc = (Path(__file__).resolve().parents[1] / 'bash/.bashrc').read_text()
        helper = bashrc[bashrc.index('# Every shell uses'):bashrc.index('\nagent-with-keys()')]
        # Redirect only this helper's paths; leave the actual HOME unchanged.
        helper = helper.replace('$HOME', '$agent_test_home')
        with tempfile.TemporaryDirectory(prefix='agent-test-') as directory:
            root = Path(directory)
            script = root / 'helper.bash'
            script.write_text(helper + '''
ssh-agent() {
  local output
  output="$(command ssh-agent "$@")" || return
  printf '%s\\n' "$output" >>"$agent_test_home/agents.log"
}
''')
            env = dict(os.environ, agent_test_home=directory)
            def run(command, check=True):
                return subprocess.run(
                    ['bash', '-c', 'source "$1"; ' + command, 'test', str(script)],
                    env=env, text=True, capture_output=True, check=check,
                )
            def pids():
                log = root / 'agents.log'
                return re.findall(r'SSH_AGENT_PID=(\d+)', log.read_text()) if log.exists() else []

            try:
                ssh_dir = root / '.ssh'
                ssh_dir.mkdir()
                config = ssh_dir / 'config'
                original = 'Host example\n  HostName example.invalid\n'
                config.write_text(original)
                # Simultaneous starts must converge even while the agent is empty.
                run('for i in {1..8}; do (_agent-setup) & done; wait')
                self.assertEqual(len(pids()), 1)
                self.assertEqual(run('ssh-add -l', check=False).returncode, 1)
                self.assertEqual(config.read_text(),
                                 'IdentityAgent ~/.ssh/dotfiles-agent/agent.sock\n' + original)
                agent_dir = ssh_dir / 'dotfiles-agent'
                self.assertEqual(agent_dir.stat().st_mode & 0o777, 0o700)
                self.assertEqual(agent_dir.stat().st_uid, os.getuid())
                socket_stat = (agent_dir / 'agent.sock').stat()
                self.assertEqual(socket_stat.st_mode & 0o077, 0)
                self.assertEqual(socket_stat.st_uid, os.getuid())

                # An independent shell can ask the shared agent to sign with a loaded key.
                key = root / 'test-key'
                subprocess.run(['ssh-keygen', '-q', '-t', 'ed25519', '-N', '', '-f', str(key)], check=True)
                run('agent "$agent_test_home/test-key"')
                run('ssh-add -T "$agent_test_home/test-key.pub"')
                run('_agent-setup')
                self.assertEqual(len(pids()), 1)
                self.assertEqual(config.read_text().count('IdentityAgent'), 1)

                # SSH config wins over an old terminal's environment.
                result = run('SSH_AUTH_SOCK=/stale/socket ssh -G -F "$agent_test_home/.ssh/config" example')
                self.assertRegex(result.stdout, r'(?m)^identityagent (?:~|' + re.escape(str(Path.home())) + r')/\.ssh/dotfiles-agent/agent\.sock$')

                # Existing directives need not be on the first line or use our socket.
                for existing in (
                    '# SSH settings\nIdentityAgent ~/.ssh/dotfiles-agent/agent.sock\n' + original,
                    '# Custom agent\nIdentityAgent /custom/agent.sock\n' + original,
                ):
                    config.write_text(existing)
                    run('_agent-setup')
                    self.assertEqual(config.read_text(), existing)

                os.kill(int(pids()[0]), signal.SIGTERM)
                sock_path = ssh_dir / 'dotfiles-agent/agent.sock'
                # Wait for the exiting agent to remove its socket before planting a stale one.
                for _ in range(100):
                    if not sock_path.exists():
                        break
                    time.sleep(0.01)
                with socket.socket(socket.AF_UNIX) as stale:
                    stale.bind(str(sock_path))
                run('_agent-setup')
                self.assertEqual(len(pids()), 2)
                self.assertEqual(run('ssh-add -l', check=False).returncode, 1)
            finally:
                for pid in pids():
                    try:
                        os.kill(int(pid), signal.SIGTERM)
                    except ProcessLookupError:
                        pass


if __name__ == '__main__':
    unittest.main()
