#!/bin/bash

die() {
  echo "$(basename "$0"): error: $*" >&2
  exit 1
}

on-macos() {
  [[ "$(uname)" = "Darwin" ]]
}

on-linux() {
  [[ "$(uname)" = Linux ]]
}

BREW_DEPS=(
  ansifilter
  asciinema
  awscli
  bash
  bat
  cargo-nextest
  cmake
  eza
  fd
  ffmpeg
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
  rsync
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

BREW_CASK_DEPS=(
  ghostty
)

setup-fzf() {
  if command -v fzf 2>/dev/null; then
    echo "Skipping fzf installation as it looks like it's already installed..."
    return 0
  fi
  fzf_dir="$HOME"/.fzf
  rm -rf "$fzf_dir"
  echo "Installing FZF..."
  git clone --depth 1 https://github.com/junegunn/fzf "$fzf_dir"
  cd "$fzf_dir" || exit
  ./install --all --no-zsh --no-fish || die "failed to install fzf"
}
apt_pkgs=(
  build-essential
  clang
  cmake
  curl
  eza
  gettext
  git
  libffi-dev
  libgmp-dev
  libncurses-dev
  libssl-dev
  ninja-build
  openssl
  pass
  pkg-config
  tmux
  universal-ctags
  unzip
)

run-install() (
  mkdir -p "$HOME"/.local/bin ||:

  if on-macos; then
      echo "Checking that homebrew is installed..."
      brew --version

      # defaults write -g InitialKeyRepeat -int 15
      # defaults write -g KeyRepeat -int 0
      # defaults write com.apple.CrashReporter DialogType none
      defaults write com.apple.finder AppleShowAllFiles true

      brew install "${BREW_DEPS[@]}" || die "brew install failed"
      for cask in "${BREW_CASK_DEPS[@]}"; do
        brew install --cask "$cask" || die "brew cask install failed for $cask"
      done
      luarocks install luacheck || die "luacheck install failed"
      luarocks install --server=https://luarocks.org/dev luaformatter || die "luaformatter install failed"
      echo "NB: make sure you manage brew services."
      brew services
      ln -sf "$HOME"/src/dotfiles/.config/ghostty/config "$HOME"/Library/Application\ Support/com.mitchellh.ghostty/config || die "failed to link ghostty config"
  elif on-linux; then
    if command -v apt 2>/dev/null; then
      sudo apt update -y
      sudo apt install -y "${apt_pkgs[@]}" || die "failed to install apt packages"
      if ! command -v nvim 2>/dev/null >/dev/null; then
        mkdir -p "$HOME"/src

        # Install NeoVIM
        git clone https://github.com/neovim/neovim "$HOME"/src/neovim
        (
          cd "$HOME"/src/neovim || die "failed to cd to neovim src dir"
          make CMAKE_BUILD_TYPE=RelWithDebInfo \
            && cd build \
            && cpack -G DEB \
            && sudo dpkg -i nvim-linux*.deb
        ) || die "failed to install neovim (see $HOME/install.log)"
      fi
    else
      sudo yum update -y
      sudo yum install -y ctags pass git tmux alacritty neovim
      sudo yum upgrade -y ctags pass git tmux alacritty neovim
    fi
  else
    die "unsupported platform [uname=$(uname)]"
  fi

  setup-fzf
)

run-install >>"$HOME"/install.log 2>&1  || die "installation failed, see $HOME/install.log for details"

[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env"
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

if ! command -v cargo 2>/dev/null >/dev/null; then
  echo "Installing Rust..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
  if ! [ -f "$HOME"/.cargo/env ]; then
    die "no cargo env found"
  fi
  . "$HOME"/.cargo/env
fi

if ! command -v flatc 2>/dev/null >/dev/null; then
  echo "Installing flatc..."
  (
    cd ~/src || die "failed to cd to src dir"
    if ! [ -d flatbuffers ]; then
      git clone --depth 1 https://github.com/google/flatbuffers || die "failed to clone flatbuffers repo"
    fi
    cd flatbuffers || die "failed to cd to flatbuffers dir" 
    cmake -G "Unix Makefiles" || die "failed to run cmake for flatbuffers"
    make -j || die "failed to make flatbuffers"
    if on-linux; then
      sudo make install
    fi
  )
fi

# Install Haskell compiler 
if ! command -v ghcup 2>/dev/null >/dev/null; then
  echo "Installing ghcup..."
  curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh
fi

# Make sure needed tools are available
git --version || die "git not installed"
curl --version || die "curl not installed"
nvim --version || die "vim not installed"
cmake --version || die "cmake not installed"
flatc --version || die "flatc not installed"
cargo --version || die "cargo not installed"
ghc --version || die "ghc not installed"


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

# Apply GNOME desktop settings (Caps Lock -> Ctrl, keybindings, etc.) when
# running inside a GNOME/dconf session. Non-fatal: a headless/TTY install
# (e.g. over SSH) has no session bus, so just skip it there.
if on-linux && command -v dconf >/dev/null 2>&1 && [[ -n "$DBUS_SESSION_BUS_ADDRESS" ]]; then
  echo "Applying GNOME settings via 'my-settings load'..."
  "$dotfiles_dir/bin/bin/my-settings" load \
    || echo "warning: 'my-settings load' failed; apply it manually from a GNOME session."
fi

echo "Dotfiles installation was successful, please logout of your shell, and log back in."
