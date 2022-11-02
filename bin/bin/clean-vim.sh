#!/bin/bash

pack_dir="$HOME/.vim/pack/plugins/start/"
fzf_dir="$HOME/.fzf"

plugin_precise() (
  package=$1
  url=$2
  branch=$3
  mkdir -p "$pack_dir" 2>/dev/null
  echo "Installing VIM plugin $package..."
  cd "$pack_dir" || exit
  git clone --depth=1 "$url" || exit
  if [[ -n "$branch" ]]; then
    cd "$(basename "$package")" || exit
    git checkout "$branch"
  fi
  echo "Installed VIM plugin $package."
)

plugin() {
  package=$1
  branch=$2
  mkdir -p "$pack_dir" 2>/dev/null
  plugin_precise "$package" "https://github.com/$package" "$branch"
}

setup-vim-packages() {
  rm -rf "$HOME/.vim"
  # plugin_precise 'soliman/prolog-vim' 'https://gitlab.inria.fr/soliman/prolog-vim'
  # plugin 'vim-autoformat/vim-autoformat'
  plugin 'junegunn/fzf.vim'
  plugin 'rhysd/vim-clang-format'
  plugin 'raimon49/requirements.txt.vim'
  # plugin 'jbmorgado/vim-pine-script'
  # plugin 'dylon/vim-antlr'
  plugin 'alx741/vim-hindent'
  plugin 'wbbradley/vim-ripgrep'
  # plugin 'editorconfig/editorconfig-vim'
  plugin 'luochen1990/rainbow'
  # IDE features
  # plugin 'stefandtw/quickfix-reflector.vim'
  # plugin 'prabirshrestha/vim-lsp'
  # plugin 'mattn/vim-lsp-settings'
  plugin 'dense-analysis/ale'
  # plugin 'neoclide/coc.nvim' release
  # plugin 'neoclide/coc-rls'
  # plugin 'neoclide/vim-jsx-improve'
  plugin 'yuezk/vim-js'
  plugin 'maxmellon/vim-jsx-pretty'
  plugin 'rust-lang/rust.vim'
  # plugin 'preservim/tagbar'
  # plugin 'metakirby5/codi.vim'
  plugin 'ap/vim-css-color'
  # plugin 'tpope/vim-rails'
  plugin 'tpope/vim-commentary'
  plugin 'tpope/vim-surround'
  # plugin 'sainnhe/sonokai'
  plugin 'tpope/vim-fugitive'
  # plugin 'sakibmoon/vim-colors-notepad-plus-plus'
  # plugin 'manasthakur/vim-asyncmake'
  # plugin 'tpope/vim-fireplace'
  # plugin 'othree/html5.vim'
  plugin 'airblade/vim-gitgutter'
  plugin 'easymotion/vim-easymotion'
  plugin 'Nymphium/vim-koka'
  # plugin 'vim-crystal/vim-crystal'
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
  # plugin 'terryma/vim-multiple-cursors'
  # plugin 'solarnz/thrift.vim'
  plugin 'hdima/python-syntax'
  # plugin 'IN3D/vim-raml'
  # plugin 'elzr/vim-json'
  # plugin 'Superbil/llvm.vim'
  # plugin 'flowtype/vim-flow'
  # plugin 'leafgarland/typescript-vim'
  # plugin 'wbbradley/typescript-vim'
  # plugin 'Quramy/tsuquyomi' # typescript plugin
  plugin 'itchyny/vim-haskell-indent'
  plugin 'itchyny/lightline.vim'
  plugin 'maximbaz/lightline-ale'
  # plugin 'gentoo/gentoo-syntax'
  # plugin 'bohlender/vim-smt2'
  # plugin 'vim-ruby/vim-ruby'
  # plugin 'uarun/vim-protobuf'

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
else
  # Some persistent settings...
  gsettings set org.gnome.Terminal.Legacy.Settings headerbar false
  gsettings set org.gnome.desktop.interface enable-animations false
fi

if [[ -n $1 ]]; then
  while [[ -n $1 ]]; do
    plugin "$1"
    shift
  done
  exit 0
fi
setup-vim-packages
setup-fzf
