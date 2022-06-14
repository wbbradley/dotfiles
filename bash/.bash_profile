# shellcheck disable=SC1090,SC1091
if [[ $(uname) = 'Darwin' ]]; then
  export BASH_SILENCE_DEPRECATION_WARNING=1
fi
[[ -f "$HOME/.bashrc" ]] && . "$HOME/.bashrc"
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
printf ''
