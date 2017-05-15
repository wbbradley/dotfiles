#!/bin/sh
# curl https://raw.githubusercontent.com/wbbradley/dotfiles/master/install.sh | bash
set -e

sudo apt-get update
sudo apt-get install -y exuberant-ctags stow git vim bash tmux

cd $HOME
mkdir src
cd src
git clone git@github.com:wbbradley/dotfiles
cd dotfiles
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

# Set up my git defaults
git config --global color.diff always
git config --global --add color.ui true
git config --global core.editor `which vim`
git config --global push.default tracking
git config --global branch.autosetuprebase always

vim +BundleInstall +qa
