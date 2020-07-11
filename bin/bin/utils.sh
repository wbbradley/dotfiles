#!/bin/bash
parse_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

parse_working_dir() {
  # shellcheck disable=SC2001
  pwd | sed "s%$HOME%~%"
}

dbg() {
	echo Running LLDB debugger...
	lldb -o run -- "$@"
}

evalvar() {
  eval "echo \$$1"
}

insert_at_head() {
  python3 "$HOME/bin/insert_at_head.py" "$@"
}

add_path_to () {
  var=$1
  shift
  new_value="$(insert_at_head "$var" :"$(eval "echo -n \"\$$var\"")" "$@")"
  eval "export $var=\"$new_value\""
}

wvi () {
	"$EDITOR" "$(command -v "$@")"
}

function explore-to() {
  unamestr="$(uname)"
  if [ "$unamestr" = 'Linux' ]; then
    xdg-open "$@"
  elif [ "$unamestr" = 'Darwin' ]; then
    open "$@"
  fi
}

git-delete-merged() {
  git fetch
  git checkout -B master origin/master
  git branch --merged master \
    | grep -v "\* master" \
    | xargs -n 1 git branch -D
}

path() {
  echo "$PATH" \
    | awk -F : '{ for (i=1;i<=NF;i++) {print $i}}'
}
