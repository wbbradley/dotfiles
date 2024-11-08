#!/bin/bash

die() {
  echo "$(basename "$0"): error: $*" >&2
  exit 1
}

on-macos() {
  [[ "$(uname)" = "Darwin" ]]
}

on-linux() {
  [[ $(barg hey you) = Linux ]]
}

BREW_DEPS=(
  alacritty
  ansifilter
  asciinema
  awscli
  bash
  bat
  cmake
  exa
  fd
  git
  go
  graphviz
  htop
  lua
  luajit
  luarocks
  neovim
  pass
  pstree
  pkg-config
  pinentry
  pinentry-mac
  postgresql@14
  reattach-to-user-namespace
  ripgrep
  shellcheck
  stylua
  rlwrap
  session-manager-plugin
  swig
  tmux
  tree-sitter
  universal-ctags
  vim
  ykman
)

mkdir -p "$HOME"/.local/bin ||:

if on-macos; then
    echo "Checking that homebrew is installed..."
    brew --version

    # defaults write -g InitialKeyRepeat -int 15
    # defaults write -g KeyRepeat -int 0
    # defaults write com.apple.CrashReporter DialogType none
    defaults write com.apple.finder AppleShowAllFiles true

    brew install "${BREW_DEPS[@]}" || die "brew install failed"
    luarocks install luacheck || die "luacheck install failed"
    luarocks install --server=https://luarocks.org/dev luaformatter || die "luaformatter install failed"
    echo "NB: make sure you manage brew services."
    brew services
elif on-linux; then
  if command -v apt 2>/dev/null; then
    # sudo apt-get update
    sudo apt-get install -y universal-ctags pass git vim tmux alacritty neovim
    sudo apt-get upgrade -y universal-ctags pass git vim tmux alacritty neovim
  else
    sudo yum update -y
    sudo yum install -y ctags pass git vim tmux alacritty neovim
    sudo yum upgrade -y ctags pass git vim tmux alacritty neovim
  fi
else
  die "unsupported platform [uname=$(uname)]"
fi

# Make sure needed tools are available
git --version > /dev/null || die "git not installed"
curl --version > /dev/null || die "curl not installed"
nvim --version > /dev/null || die "vim not installed"


dotfiles_dir="$HOME/src/dotfiles"

(
  # Don't try to link . and ..
  find "$dotfiles_dir/bash" "$dotfiles_dir/vim" "$dotfiles_dir/tmux/$(uname)" -maxdepth 1 -type f -print0 -name '.*' | \
    while IFS= read -r -d '' file; do
      homedir_filename="${HOME:?}/$(basename "$file")"
      if [[ -f "$homedir_filename" ]]; then
          mv "$homedir_filename" "$homedir_filename.bak"
      fi

      echo "linking '$homedir_filename' -> '$file'"
      ln -sf "$file" "$homedir_filename"
    done
)

# Install ripgrep.
if on-linux && ! rg >/dev/null 2>/dev/null && on-linux; then
  (
    cd /var/tmp || die "failed to cd to /var/tmp"
    trap "rm -rf ripgrep-*" EXIT
    ripgrep_ver=14.0.3
    curl -LO https://github.com/BurntSushi/ripgrep/releases/download/"$ripgrep_ver"/ripgrep-"$ripgrep_ver"-x86_64-unknown-linux-musl.tar.gz
    tar xf ripgrep-*-linux-musl.tar.gz
    cp ripgrep-*/rg "$HOME/.local/bin/rg"
  )
fi

if ! [[ -h "$HOME"/.config ]]; then
  mv "$HOME"/.config{,.bak}
  echo "Linking ~/.config to ~/src/dotfiles/.config..."
  ln -s "$HOME"/src/dotfiles/.config "$HOME"/
fi

rm -rf "${HOME:?}/bin"
ln -sf "$dotfiles_dir/bin/bin" "$HOME/bin" || die "failed to link bin dir"

echo "Dotfiles installation was successful, please logout of your shell, and log back in."
