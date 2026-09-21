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
