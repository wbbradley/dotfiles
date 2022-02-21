#!/bin/bash
bgfg() {
  printf "\001\033[48;2;$1;$2;$3;38;2;$4;$5;$6m\002"
}

bgfgx() {
  # HEX
  printf "\001\033[48;2;$(( 0x"$1" ));$(( 0x"$2" ));$(( 0x"$3" ));38;2;$(( 0x"$4" ));$(( 0x"$5" ));$(( 0x"$6" ))m\002"
}

reset-color() {
  printf "\001\033[0m\002"
}

bgfgx6() {
  # Convert 2 24-bit Hexadecimal colors into 6-cube colors.
  # Returns ANSI escape code for the given bg/fg combo.
  bg_r="$(( 0x"$1"*6/255 ))"
  bg_g="$(( 0x"$2"*6/255 ))"
  bg_b="$(( 0x"$3"*6/255 ))"
  fg_r="$(( 0x"$4"*6/255 ))"
  fg_g="$(( 0x"$5"*6/255 ))"
  fg_b="$(( 0x"$6"*6/255 ))"
  bg_color="$(( 16 + bg_r * 36 + bg_g * 6 + bg_b ))"
  fg_color="$(( 16 + fg_r * 36 + fg_g * 6 + fg_b ))"
  printf "\001\033[48;5;$bg_color;38;5;${fg_color}m\002"
}

host_color() {
  if [[ "$HOSTNAME" = "blade" ]]; then
    bgfg 219 98 50 14 55 13
  elif [[ "$HOSTNAME" = "fennario" ]]; then
    bgfgx6 6a 6a 6a f5 f5 f5
  else
    bgfgx6 e9 c4 6a 26 46 53
  fi
}

parse_git_branch() {
  (
    printf "%s:%s" \
      "$(git branch --color=never 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/')" \
      "$(git reflog -1 --color=never | cut -d ' ' -f1)"
  ) 2>/dev/null
}

show-env-vars() {
  declare -a vars
  vars=( VIRTUAL_ENV DEBUG AWS_PROFILE )
  i=0
  wrote=0
  delim='\n'
  for var in "${vars[@]}"; do
    (( i+=2 ))
    if [[ -n "${!var}" ]]; then
      printf "$delim$(bgfgx6 a0 50 "$(( 80 * i ))" 15 15 0) $var=%s $(reset-color)\n$(reset-color)" ${!var}
      delim=''
      (( wrote=1 ))
    fi  
  done
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

append_path() {
  python3 "$HOME/bin/append_to_set.py" "$@"
}

prepend_path_to () {
  var=$1
  shift
  new_value="$(insert_at_head "$var" :"$(eval "echo -n \"\$$var\"")" "$@")"
  eval "export $var=\"$new_value\""
}

append_path_to () {
  var=$1
  shift
  new_value="$(append_path "$var" :"$(eval "echo -n \"\$$var\"")" "$@")"
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
