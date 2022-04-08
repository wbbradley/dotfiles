#!/bin/bash

die() {
  echo "$(basename "$0"): error: $*" >&2
  exit 1
}

on-macos() {
  [[ "$(uname)" = "Darwin" ]]
}

on-linux() {
  [[ "$(uname)" = "Linux" ]]
}

BREW_DEPS=(
  bash
  bat
  cmake
  ctags-exuberant
  exa
  git
  go
  pass
  reattach-to-user-namespace
  ripgrep
  swig
  tmux
  vim
)

if on-macos; then
    echo "Checking that homebrew is installed..."
    brew --version

    defaults write -g InitialKeyRepeat -int 15
    defaults write -g KeyRepeat -int 0
    defaults write com.apple.finder AppleShowAllFiles true

    brew install "${BREW_DEPS[@]}"
elif on-linux; then
  if command -v apt 2>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y exuberant-ctags pass stow git vim tmux
    sudo apt-get upgrade -y exuberant-ctags pass stow git vim tmux
  else
    sudo yum update -y
    sudo yum install -y ctags pass git vim tmux
    sudo yum upgrade -y ctags pass git vim tmux
  fi
else
  die "unsupported platform [uname=$(uname)]"
fi

# Make sure needed tools are available
git --version > /dev/null || die "git not installed"
curl --version > /dev/null || die "curl not installed"
vim --version > /dev/null || die "vim not installed"


dotfiles_dir="$HOME/src/dotfiles"

(
  # Don't try to link . and ..
  GLOBIGNORE="$dotfiles_dir/*/.:$dotfiles_dir/*/.."
  for file in "$dotfiles_dir"/bash/.* "$dotfiles_dir"/vim/.* "$dotfiles_dir/tmux/$(uname)/".*; do
    homedir_filename="${HOME:?}/$(basename "$file")"
    if [[ -f "$homedir_filename" ]]; then
        mv "$homedir_filename" "$homedir_filename.bak"
    fi

    echo "linking '$homedir_filename' -> '$file'"
    ln -sf "$file" "$homedir_filename"
  done
)

if ! rg >/dev/null 2>/dev/null && on-linux; then
  (
    cd /var/tmp
    trap "rm -rf ripgrep-13.0.0-*" EXIT
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/13.0.0/ripgrep-13.0.0-x86_64-unknown-linux-musl.tar.gz
    tar xf ripgrep-*-linux-musl.tar.gz
    cp ripgrep-*/rg "$HOME/bin/rg"
  )
fi

rm -rf "${HOME:?}/bin"
ln -sf "$dotfiles_dir/bin/bin" "$HOME/bin" || die "failed to link bin dir"

echo "Dotfiles installation was successful, please logout of your shell, and log back in."
echo "Run clean-vim.sh at any time to set up vim, or to reset it."
