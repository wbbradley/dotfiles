#!/bin/bash

pack_dir="$HOME/.vim/pack/plugins/start/"
fzf_dir="$HOME/.fzf"

plugin() {
  package=$1
  branch=$2
  mkdir -p "$pack_dir" 2>/dev/null
  echo "Installing VIM plugin $package..."
  cd "$pack_dir" || exit
  git clone --depth=1 "https://github.com/$package" || exit
  if [ "$branch" != "" ]; then
    cd "$(basename "$package")" || exit
    git checkout "$branch"
  fi
  echo "Installed VIM plugin $package."
}

setup-vim-packages() {
  rm -rf "$HOME/.vim"
  plugin 'junegunn/fzf.vim'
  plugin 'rhysd/vim-clang-format'
  plugin 'jbmorgado/vim-pine-script'
  plugin 'dylon/vim-antlr'
  plugin 'alx741/vim-hindent'
  plugin 'editorconfig/editorconfig-vim'

  # IDE features

  plugin 'dense-analysis/ale'
  # plugin 'neoclide/coc.nvim' release
  # plugin 'neoclide/coc-rls'
  plugin 'neoclide/vim-jsx-improve'
  # plugin 'rust-lang/rust.vim'
  # plugin 'metakirby5/codi.vim'
  plugin 'ap/vim-css-color'
  plugin 'tpope/vim-rails'
  plugin 'tpope/vim-commentary'
  plugin 'tpope/vim-surround'
  plugin 'sainnhe/sonokai'
  plugin 'tpope/vim-fugitive'
  plugin 'sakibmoon/vim-colors-notepad-plus-plus'
  # plugin 'tpope/vim-fireplace'
  # plugin 'othree/html5.vim'
  plugin 'nvie/vim-flake8'
  plugin 'airblade/vim-gitgutter'
  plugin 'easymotion/vim-easymotion'
  plugin 'vim-crystal/vim-crystal'
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
  # plugin 'christoomey/vim-tmux-navigator'
  # plugin 'sjl/threesome.vim.git'
  # plugin 'bling/vim-airline'
  # plugin 'toyamarinyon/vim-swift'
  # plugin 'ryanss/vim-hackernews'

  plugin 'fatih/vim-go'
  plugin 'terryma/vim-expand-region'
  plugin 'terryma/vim-multiple-cursors'
  # plugin 'solarnz/thrift.vim'
  plugin 'hdima/python-syntax'
  # plugin 'IN3D/vim-raml'
  # plugin 'elzr/vim-json'
  # plugin 'Superbil/llvm.vim'
  # plugin 'flowtype/vim-flow'
  # plugin 'leafgarland/typescript-vim'
  # plugin 'wbbradley/typescript-vim'
  plugin 'Quramy/tsuquyomi'
  plugin 'itchyny/vim-haskell-indent'
  plugin 'itchyny/lightline.vim'
  plugin 'maximbaz/lightline-ale'
  plugin 'gentoo/gentoo-syntax'
  plugin 'bohlender/vim-smt2'
  plugin 'vim-ruby/vim-ruby'

  if [[ -d "$HOME/src/vim-zion" ]]; then
    (cd "$pack_dir" && ln -s "$HOME/src/vim-zion" vim-zion)
  else
    plugin 'zionlang/vim-zion'
  fi
  if [[ -d "$HOME/src/miramare" ]]; then
    (cd "$pack_dir" && ln -s "$HOME/src/miramare" miramare)
  else
    plugin 'wbbradley/miramare'
  fi
  vim "+helptags ALL" "+q"
}

setup-fzf() {
  rm -rf "$HOME/.fzf"
  git clone https://github.com/junegunn/fzf "$fzf_dir"
  cd "$fzf_dir" || exit
  ./install --all --no-zsh --no-fish || exit
  ln -s "$fzf_dir" "$pack_dir/fzf"
}

if [ "$(uname)" = "Darwin" ]; then
  brew upgrade vim
fi

setup-vim-packages
setup-fzf
