#!/bin/bash

pack_dir="$HOME/.vim/pack/plugins/start/"
fzf_dir="$HOME/.fzf"

plugin() {
  package=$1
  mkdir -p "$pack_dir" 2>/dev/null
  echo "Installing VIM plugin $package..."
  cd "$pack_dir" || exit
  git clone --depth=1 "https://github.com/$package" || exit
  echo "Installed VIM plugin $package."
}

setup-vim-packages() {
  rm -rf "$HOME/.vim"
  plugin 'junegunn/fzf.vim'
  plugin 'rhysd/vim-clang-format'
  plugin 'alx741/vim-hindent'
  plugin 'editorconfig/editorconfig-vim'
  plugin 'dense-analysis/ale'
  # plugin 'mileszs/ack.vim'
  # plugin 'tpope/vim-fireplace'
  # plugin 'othree/html5.vim'
  # plugin 'vim-scripts/YankRing.vim'
  # plugin 'maxbrunsfeld/vim-yankstack'
  # plugin 'jmcantrell/vim-virtualenv'
  # plugin 'vim-scripts/django.vim'
  plugin 'nvie/vim-flake8'
  plugin 'airblade/vim-gitgutter'
  plugin 'tpope/vim-fugitive'
  # plugin 'tpope/vim-dispatch'
  # plugin 'tpope/vim-unimpaired'
  # plugin 'kchmck/vim-coffee-script.git'
  # plugin 'jimmyhchan/dustjs.vim.git'
  # plugin 'juvenn/mustache.vim.git'
  # plugin 'Lokaltog/vim-easymotion'
  # plugin 'groenewege/vim-less'
  # plugin 'rking/ag.vim'
  # plugin 'fweep/vim-tabber'
  # plugin 'pangloss/vim-javascript'
  # plugin 'mxw/vim-jsx'
  # plugin 'scrooloose/syntastic'

  # plugin 'bitc/vim-hdevtools'
  plugin 'hynek/vim-python-pep8-indent.git'
  plugin 'christoomey/vim-tmux-navigator'
  # plugin 'sjl/threesome.vim.git'
  # plugin 'bling/vim-airline'
  # plugin 'toyamarinyon/vim-swift'
  # plugin 'ryanss/vim-hackernews'

  plugin 'fatih/vim-go'
  vim +GoUpdateBinaries +q

  plugin 'terryma/vim-expand-region'
  plugin 'terryma/vim-multiple-cursors'
  # plugin 'solarnz/thrift.vim'
  plugin 'hdima/python-syntax'
  # plugin 'IN3D/vim-raml'
  # plugin 'elzr/vim-json'
  # plugin 'Superbil/llvm.vim'
  # plugin 'flowtype/vim-flow'
  # plugin 'leafgarden/typescript-vim'
  plugin 'itchyny/vim-haskell-indent'
  plugin 'itchyny/lightline.vim'
  plugin 'maximbaz/lightline-ale'
  plugin 'gentoo/gentoo-syntax'

  vim "+helptags ALL" "+q"
}

setup-fzf() {
  rm -rf "$HOME/.fzf"
  git clone https://github.com/junegunn/fzf "$fzf_dir"
  cd "$fzf_dir" || exit
  ./install --all --no-zsh --no-fish || exit
  ln -s "$fzf_dir" "$pack_dir/fzf"
}

setup-vim-packages
setup-fzf
