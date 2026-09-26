dotfiles

# Installation

```sh
curl https://raw.githubusercontent.com/wbbradley/dotfiles/master/install.sh | bash
```

Considering bringing more of
https://raw.githubusercontent.com/tamdogood/builder-essential-skills/refs/heads/main/skills/orwell-writing/SKILL.md
in.

## tmux colors

The Linux and Darwin tmux configs both source `.config/tmux/gruvbox.conf`
through `~/.config`, which the installer links to this repository. Edit that
shared file to change the Gruvbox status bar, pane borders, copy-mode colors,
or pane flashes. Pane foreground and background inherit the terminal colors.

Reload an existing session with `tmux source-file ~/.tmux.conf`.

## Alt select all, copy and paste (GNOME 50)

Run `~/bin/setup-alt-clipboard`, then log out and back in. The installer also
runs this setup. The local GNOME extension in `X/gnome-shell/extensions/`
maps Alt+C to Ctrl+C in GUI apps and Ctrl+Shift+C in Alacritty and common
terminals. Alt+V sends Ctrl+Shift+V everywhere (often paste without formatting
in GUI apps). Alacritty also has native Alt+C/Alt+V clipboard bindings for use
without the extension. Alt+A sends Ctrl+A to select all in the focused text field
(including Chrome and Slack). Outside text fields, it performs the focused app's
Ctrl+A action; in terminals this commonly moves to the start of the command line.
Regular Ctrl shortcuts remain available.

Release Alt to perform the action. Pending actions are cancelled if focus
changes or Alt remains held for five seconds. The extension handles windows
and the overview, but is inactive on the lock screen. It takes precedence over
app shortcuts such as Alt+A/Alt+C/Alt+V menu accelerators. GNOME Terminal's stored
copy/paste shortcuts are restored to Ctrl+Shift+C/V for forwarding.

To use ordinary Ctrl+V paste in GUI apps (terminals still use Ctrl+Shift+V):

```sh
gsettings --schemadir ~/.local/share/gnome-shell/extensions/alt-clipboard@dotfiles/schemas \
  set org.gnome.shell.extensions.alt-clipboard paste-with-shift false
```

To disable the desktop mappings, run `gnome-extensions disable alt-clipboard@dotfiles`.
After editing the extension, rerun setup and log out and back in.

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
