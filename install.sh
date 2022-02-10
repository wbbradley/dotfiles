#!/bin/bash
# curl https://raw.githubusercontent.com/wbbradley/dotfiles/master/install.sh | bash

die() {
  echo "$0: error: $*" >&2
  echo "$0: quitting..." >&2
  exit 1
}

if [ $(uname) == 'Darwin' ]; then
    echo "Checking that homebrew is installed..."
    brew --version

    echo "Making the keyboard not slow..."
    defaults write -g InitialKeyRepeat -int 15
    defaults write -g KeyRepeat -int 0

    echo "Making Finder show more files..."
    defaults write com.apple.finder AppleShowAllFiles true

    echo "Getting Exuberant-Ctags..."
    brew install ctags-exuberant reattach-to-user-namespace go git vim bash tmux stow
fi

if [ "$(uname)" == 'Linux' ]; then
  if command -v apt 2>/dev/null; then
    sudo apt-get update
    sudo apt-get install -y exuberant-ctags stow git vim bash tmux
    sudo apt-get upgrade -y exuberant-ctags stow git vim bash tmux
  else
    sudo yum update -y
    sudo yum install -y exuberant-ctags stow git vim bash tmux
    sudo yum upgrade -y exuberant-ctags stow git vim bash tmux
  fi
fi

# Make sure needed tools are available
git --version > /dev/null || die "git not installed"
curl --version > /dev/null || die "curl not installed"
vim --version > /dev/null || die "vim not installed"
stow --version > /dev/null || die "stow not installed"

cd "$HOME" || die "no home"
mkdir -p "$HOME/src"
cd "$HOME/src" || die "no src dir?"
rm -rf dotfiles
git clone git@github.com:wbbradley/dotfiles || die "failed to clone dotfiles"
cd "$HOME/src/dotfiles" || die "no dotfiles dir?"

if [ -f "$HOME/.bashrc" ]; then
    mv "$HOME/.bashrc" "$HOME/.bashrc.bak"
fi

stow -t "$HOME" bash || die "failed to stow bash"
stow -t "$HOME" vim || die "failed to stow vim"
(
  cd tmux || die "no tmux dir in dotfiles?"
  stow -t "$HOME" "$(uname)"
) || die "failed to stow tmux"
stow -t "$HOME" bin "failed to stow bin dir"

# Set up my git defaults
git config --global color.diff always
git config --global --add color.ui true
git config --global push.default simple
git config --global branch.autosetuprebase always
git config --global merge.ff only
git config --global merge.tool vimdiff

echo "Dotfiles installation was successful, please logout of your shell, and log back in."
echo "Run clean-vim.sh at any time to set up vim, or to reset it."
