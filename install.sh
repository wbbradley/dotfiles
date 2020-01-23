#!/bin/bash
# curl https://raw.githubusercontent.com/wbbradley/dotfiles/master/install.sh | bash
set -ex

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

if [ $(uname) == 'Linux' ]; then
    sudo apt-get update
    sudo apt-get install -y exuberant-ctags stow git vim bash tmux
    sudo apt-get upgrade -y exuberant-ctags stow git vim bash tmux
fi

# Make sure needed tools are available
git --version > /dev/null
curl --version > /dev/null
vim --version > /dev/null
stow --version > /dev/null

cd $HOME
mkdir -p $HOME/src
cd $HOME/src
rm -rf dotfiles
git clone git@github.com:wbbradley/dotfiles
cd $HOME/src/dotfiles
git submodule init
git submodule update

if [ -f $HOME/.bashrc ]; then
    mv $HOME/.bashrc $HOME/.bashrc.bak
fi

stow -t $HOME bash
stow -t $HOME vim
(cd tmux && stow -t $HOME `uname`)
stow -t $HOME bin

# Set up my git defaults
git config --global color.diff always
git config --global --add color.ui true
git config --global push.default tracking
git config --global branch.autosetuprebase always
git config --global merge.ff only

vim +BundleInstall +qa

echo "Dotfiles installation was successful, please logout of your shell, and log back in."
