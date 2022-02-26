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
  cmake
  ctags-exuberant
  exa
  git
  go
  reattach-to-user-namespace
  ripgrep
  swig
  tmux
  vim
)

if on-macos; then
    echo "Checking that homebrew is installed..."
    brew --version

    echo "Making the keyboard not slow..."
    defaults write -g InitialKeyRepeat -int 15
    defaults write -g KeyRepeat -int 0

    echo "Making Finder show more files..."
    defaults write com.apple.finder AppleShowAllFiles true

    echo "Getting Exuberant-Ctags..."
    brew install "${BREW_DEPS[@]}"
elif on-linux; then
  if command -v apt 2>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y exuberant-ctags stow git vim bash tmux
    sudo apt-get upgrade -y exuberant-ctags stow git vim bash tmux
  else
    sudo yum update -y
    sudo yum install -y exuberant-ctags git vim bash tmux
    sudo yum upgrade -y exuberant-ctags git vim bash tmux
  fi
else
  die "unsupported platform [uname=$(uname)]"
fi

# Make sure needed tools are available
git --version > /dev/null || die "git not installed"
curl --version > /dev/null || die "curl not installed"
vim --version > /dev/null || die "vim not installed"


dotfiles_dir="$HOME/src/dotfiles"

for file in "$dotfiles_dir"/bash/.* "$dotfiles_dir"/vim/.* "$dotfiles_dir/tmux/$(uname)/".*; do
  homedir_filename="${HOME:?}/$(basename "$file")"
  if [[ -f "$homedir_filename" ]]; then
      mv "$homedir_filename" "$homedir_filename.bak"
  fi

  echo "linking '$homedir_filename' -> '$file'"
  ln -sf "$file" "$homedir_filename"
done

rm -rf "${HOME:?}/bin"
ln -sf "$dotfiles_dir/bin/bin" "$HOME/bin" || die "failed to link bin dir"

echo "Dotfiles installation was successful, please logout of your shell, and log back in."
echo "Run clean-vim.sh at any time to set up vim, or to reset it."
