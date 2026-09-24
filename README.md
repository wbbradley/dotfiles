dotfiles
========

# Installation

```sh
curl https://raw.githubusercontent.com/wbbradley/dotfiles/master/install.sh | bash
```

Considering bringing more of
https://raw.githubusercontent.com/tamdogood/builder-essential-skills/refs/heads/main/skills/orwell-writing/SKILL.md
in.

## Voxtype (GNOME Wayland)

`.config/voxtype/config.toml` configures local Whisper medium, English
transcription, direct typing, and silent start/stop. The installer links
`~/.config` here and restores the Ctrl+F12 toggle shortcut from `X/dconf.ini`
through `my-settings load`.

Voxtype and its typing backend must be installed separately. The shortcut
expects `/usr/local/bin/voxtype`. On this machine, Voxtype uses the Vulkan
build with an NVIDIA GPU and `ydotool` for GNOME text injection. The ydotool
user service needs access to `/dev/uinput`.

After installing those prerequisites, download the model and enable the services:

```sh
voxtype setup --download --model medium
systemctl --user enable --now ydotool
voxtype setup systemd
```

Models stay outside Git in `~/.local/share/voxtype/models/`. After changing
Voxtype settings, run `systemctl --user restart voxtype`.

## Shared SSH agent

Run `agent` to start or reuse a per-user agent and load `~/.ssh/id_ed25519`.
Pass other key paths or `ssh-add` options as arguments, for example
`agent ~/.ssh/work_key` or `agent -l`.

The socket lives in a directory owned by your user with mode `700`; a private
umask prevents group or other users from accessing the socket.

The first call prepends `IdentityAgent ~/.ssh/dotfiles-agent/agent.sock` to
`~/.ssh/config` unless a line beginning with `IdentityAgent` already exists,
preserving the existing contents. This lets SSH (including
Git's SSH calls) in already-open terminals find the agent regardless of their
`SSH_AUTH_SOCK`. Commands that explicitly override `IdentityAgent` or use a
separate SSH config can override this default. If your config is a symlink,
add that line at its top yourself.

New Bash sessions also export the fixed socket for `ssh-add` and other agent
clients. In an existing terminal, run `source ~/.bashrc` to load the new
function and environment. The agent survives closing terminals; after a
reboot or agent termination, run `agent` again to reload keys. Existing keys
in other agents are not transferred. This explicitly selects the local shared
agent even in sessions with SSH agent forwarding.
