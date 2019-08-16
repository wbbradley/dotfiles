[[ -f "${HOME}/.bashrc" ]] && . "$HOME/.bashrc"
[[ -f "${HOME}/xmodmap.file" ]] && xmodmap -v "${HOME}/xmodmap.file"

# My xmodmap.file looks like this because I have a Macally SLIMKEYC keyboard.
# This setup enables me to always lock the fn keys, but still use the arrow
# keys as normal keys, instead of their mapping to pgup, pgdn, home, end.
: '
  keycode 112 = Up
  keycode 117 = Down
  keycode 110 = Left
  keycode 115 = Right
'
