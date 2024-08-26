# shellcheck disable=SC1090,SC1091
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
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
