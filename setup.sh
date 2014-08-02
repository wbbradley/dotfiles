#!/bin/bash

mkdir $HOME/src
cd $HOME/src
git clone https://github.com/milkbikis/powerline-shell
cd powerline-shell
./install.py
mkdir -p $HOME/.vim/autoload ~/.vim/bundle && curl -LSso $HOME/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
cd $HOME/src
git clone https://github.com/wbbradley/dotfiles.git
cd dotfiles
./install.py
vi +BundleInstall
