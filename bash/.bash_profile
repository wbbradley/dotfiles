# shellcheck disable=SC1090,SC1091
export XDG_CONFIG_HOME="$HOME"/.config
if [[ $(uname) = 'Darwin' ]]; then
  export BASH_SILENCE_DEPRECATION_WARNING=1
  if [[ -d /usr/local/sbin ]]; then
    export PATH="/usr/local/sbin:$PATH"
  fi
fi
[[ -f "$HOME/.bashrc" ]] && . "$HOME/.bashrc"
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
printf ''
