#!/bin/bash
look-for-trap() {
  dir="$1"
  kind="$2"
  files=$3
  # Get all the untracked files
  for f in $files; do
    if [ -f "${f}" ]; then
      # look for traps \
      if grep -n -E '\btrap\b.*INT' "$f"; then
        echo "Found a $kind trap in $dir/${f}!"
      fi
    fi
  done
}

look-for-trap "$(pwd)" "whatever" "$(find . -type f)"
look-for-trap "$(pwd)" "dirty" "$(git ls-files . --ignored --exclude-standard --others \
  | grep -v -e pyc -e contrib -e tags)"
look-for-trap "$(pwd)" "checked-in" "$(git ls-files .)"
