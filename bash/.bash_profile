# shellcheck disable=SC1090
[[ -f "${HOME}/.bashrc" ]] && . "$HOME/.bashrc"
[[ -f "${HOME}/xmodmap.file" ]] && xmodmap -v "${HOME}/xmodmap.file"
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
(command -v rbenv 1>/dev/null 2>/dev/null) && eval "$(rbenv init -)"
export NVM_DIR="$HOME/.nvm"
# nvm="$(brew --prefix nvm)"
# nvm="/usr/local/opt/nvm"
# if [ -n "$nvm" ]; then
  # [ -s "$nvm/nvm.sh" ] && . "$nvm/nvm.sh"
  # [ -s "$nvm/etc/bash_completion.d/nvm" ] && . "$nvm/etc/bash_completion.d/nvm"
# fi
