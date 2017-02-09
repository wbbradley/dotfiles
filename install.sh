#! /bin/sh
set -e

apt-get install -y exuberant-ctags stow

# Make sure needed tools are available
git --version > /dev/null
curl --version > /dev/null
vim --version > /dev/null
stow --version > /dev/null

stow -t $HOME bash
stow -t $HOME vim
stow -t $HOME tmux

# Set up my git defaults
git config --global color.diff always
git config --global --add color.ui true
git config --global core.editor `which vim`
git config --global push.default tracking
git config --global branch.autosetuprebase always

rm -rf ~/.vim/bundle
rm -rf ~/.vim/autoload
mkdir -p ~/.vim/bundle
mkdir -p ~/.vim/autoload
git clone git@github.com:gmarik/vundle $HOME/.vim/bundle/vundle
curl -Sso ~/.vim/autoload/pathogen.vim https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim
