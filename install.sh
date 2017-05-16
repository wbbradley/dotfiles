#!/bin/sh
# curl https://raw.githubusercontent.com/wbbradley/dotfiles/master/install.sh | bash
set -e

if [ $(uname) == 'Darwin' ]; then
    echo "Checking that homebrew is installed..."
    brew --version

    echo "Making the keyboard not slow..."
    defaults write -g InitialKeyRepeat -int 15
    defaults write -g KeyRepeat -int 0

    echo "Making Finder show more files..."
    defaults write com.apple.finder AppleShowAllFiles true

    echo "Getting Exuberant-Ctags..."
    brew install ctags-exuberant reattach-to-user-namespace go
fi

if [ $(uname) == 'Linux' ]; then
    sudo apt-get update
    sudo apt-get install -y exuberant-ctags stow git vim bash tmux
fi

cd $HOME
mkdir -p $HOME/src
cd $HOME/src
git clone git@github.com:wbbradley/dotfiles
cd $HOME/src/dotfiles
git submodule init
git submodule update

# Make sure needed tools are available
git --version > /dev/null
curl --version > /dev/null
vim --version > /dev/null
stow --version > /dev/null

mv ~/.bashrc ~/.bashrc.bak
stow -t $HOME bash
stow -t $HOME vim
stow -t $HOME tmux
stow -t $HOME bin

# Set up my git defaults
git config --global color.diff always
git config --global --add color.ui true
git config --global core.editor `which vim`
git config --global push.default tracking
git config --global branch.autosetuprebase always

vim +BundleInstall +qa

echo "Dotfiles installation was successful, please logout of your shell, and log back in."
