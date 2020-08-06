#!/bin/bash

function zion-archive() {
  cd ~/src/zion || return 1
  git commit -am wip
  git push || {
    echo "Failed to push!";
      return 1
    }
  # sha="$(curl -LO https://github.com/zionlang/zion/archive/master.tar.gz 2>/dev/null | shasum -a 256 | awk '{ printf("%s", $1) }')"
  cd ~/src/homebrew-zion || return 1
  # <zion.rb sed -E 's/  sha256 ".*/  sha256 "'"$sha"'"/' >zion2.rb
  # mv zion2.rb zion.rb
  git commit -am wip
  git push
}

function brewtest() {
  set -x
  trap 'set +x' EXIT
  brew remove --quiet --force zion
  zion-archive
  rm -f "$HOME"/Library/Caches/Homebrew/downloads/*zion-master*.tar.gz
  rm -rf /usr/local/Homebrew/Library/Taps/zionlang
  brew install --debug --verbose zionlang/zion/zion
  set +x
}

function brewtags() {
  ctags-ruby --exclude=Formula /usr/local/Homebrew
}

