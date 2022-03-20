#!/usr/bin/env bash

die() {
  echo "$(basename "$0"): error: $*" >&2
  exit 1
}

command-exists() {
  command -v "$1" >/dev/null 2>/dev/null
}

on-linux() {
  [[ "$(uname)" = "Linux" ]]
}

on-apt-linux() {
  on-linux && command-exists apt
}

on-yum-linux() {
  on-linux && command-exists yum
}

on-macos() {
  [[ "$(uname)" = "Darwin" ]]
}

if on-macos; then
  if ! command -v brew >/dev/null 2>/dev/null; then
    /usr/bin/env bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  brew install git
elif on-apt-linux; then
  sudo apt install -y git
elif on-yum-linux; then
  sudo yum install -y git
fi

if ! command-exists git; then
  die "git is not available. oh no!"
fi

mkdir -p "$HOME/src"
git clone git@github.com:wbbradley/dotfiles.git "$HOME/src/dotfiles"
"$HOME/src/dotfiles/install.sh"
