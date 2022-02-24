#!/bin/bash

die() {
  echo "$(basename "$0"): error: $*" >&2
  exit 1
}

BREW_DEPS=(
  bash
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

if [[ $(uname) == 'Darwin' ]]; then
    echo "Checking that homebrew is installed..."
    brew --version

    echo "Making the keyboard not slow..."
    defaults write -g InitialKeyRepeat -int 15
    defaults write -g KeyRepeat -int 0

    echo "Making Finder show more files..."
    defaults write com.apple.finder AppleShowAllFiles true

    echo "Getting Exuberant-Ctags..."
    brew install "${BREW_DEPS[@]}"
fi

if [[ "$(uname)" == 'Linux' ]]; then
  if command -v apt 2>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y exuberant-ctags stow git vim bash tmux
    sudo apt-get upgrade -y exuberant-ctags stow git vim bash tmux
  else
    sudo yum update -y
    sudo yum install -y exuberant-ctags git vim bash tmux
    sudo yum upgrade -y exuberant-ctags git vim bash tmux
  fi
fi

# Make sure needed tools are available
git --version > /dev/null || die "git not installed"
curl --version > /dev/null || die "curl not installed"
vim --version > /dev/null || die "vim not installed"


dotfiles_dir="$HOME/src/dotfiles"

for file in "$dotfiles_dir"/bash/.* "$dotfiles_dir"/vim/.* "$dotfiles_dir/tmux/$(uname)/".*; do
  homedir_filename="$HOME/$(basename "$file")"
  if [[ -f "$homedir_filename" ]]; then
      mv "$homedir_filename" "$homedir_filename.bak"
  fi

  echo "linking '$homedir_filename' -> '$file'"
  ln -sf "$file" "$homedir_filename"
done

ln -s "$dotfiles_dir/bin/bin" "$HOME/bin" || die "failed to link bin dir"

# Set up my git defaults
git config --global color.diff always
git config --global --add color.ui true
git config --global push.default simple
git config --global branch.autosetuprebase always
git config --global merge.ff only
git config --global merge.tool vimdiff

echo "Dotfiles installation was successful, please logout of your shell, and log back in."
echo "Run clean-vim.sh at any time to set up vim, or to reset it."
