[[ -f "${HOME}/.bashrc" ]] && . "$HOME/.bashrc"
[[ -f "${HOME}/xmodmap.file" ]] && xmodmap -v "${HOME}/xmodmap.file"
# (command -v rbenv 1>/dev/null 2>/dev/null) && eval "$(rbenv init -)"
