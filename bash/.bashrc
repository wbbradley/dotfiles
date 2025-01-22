#!/bin/bash
# vim: ft=bash
# shellcheck disable=SC1090,SC1091,SC2207
[[ $- != *i* ]] && return

export BASH_SILENCE_DEPRECATION_WARNING=1
export PATH=/opt/homebrew/opt/openjdk/bin:"$PATH"
export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export FZF_DEFAULT_COMMAND="rg --files"
# --iglob '*' --iglob '.*' --iglob '!*.swp' --iglob '!.*.swp' --iglob '!*.pyc' --iglob '!.git/' --iglob '!env/bin' --iglob '!node_modules' --iglob '!.*env/'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  fi
  if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
  if [ -d /usr/local/etc/bash_completion.d ]; then
    for f in /usr/local/etc/bash_completion.d/*; do
      . "$f"
    done
  fi
  if [ -d /opt/homebrew/etc/bash_completion.d ]; then
    PATH=/opt/homebrew/bin:$PATH
    for f in /opt/homebrew/etc/bash_completion.d/*; do
      . "$f"
    done
  fi
  if [ -d /opt/homebrew/share/bash-completion/completions ]; then
    for f in /opt/homebrew/share/bash-completion/completions/*
      do
        . "$f"
      done
  fi
fi

_ssh() {
    local cur opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    opts=$(grep '^Host' ~/.ssh/config ~/.ssh/config.d/* 2>/dev/null | grep -v '[?*]' | cut -d ' ' -f 2-)

    # shellcheck disable=SC2086
    COMPREPLY=( $(compgen -W "$opts" -- ${cur}) )
    return 0
}
complete -F _ssh ssh

export FIGNORE=".dvi:.aux:.out:.ps1:"

fix-ssh() {
  sock="$(tmux showenv SSH_AUTH_SOCK)"
  if [[ -n "$sock" ]]; then
    eval "$sock"
    ssh -T git@github.com
  else
    echo "error: fix-ssh: tmux has no SSH_AUTH_SOCK env var!" >&2
  fi
  if [[ -n "$SSH_AUTH_SOCK" ]]; then
    echo "ssh config should be good to go"
    return 0
  else
    echo "ssh-agent does not seem to be running, or we couldn't find the SSH_AUTH_SOCK"
    return 1
  fi
}

hr() {
  for ((i=0; i < COLUMNS - 1; ++i)); do
    printf '▒'
  done
  printf '\n'
}

new-main() {
  git fetch
  main="$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"
  if [[ -n "$1" ]] && [[ -n "$main" ]]; then
    git checkout -B "$1" "origin/$main"
  else
    git checkout -B "$main" "origin/$main"
  fi
}

. "$HOME/bin/utils.sh"

if [[ -d /opt/homebrew/bin ]]; then
  prepend_path_to PATH /opt/homebrew/sbin
  prepend_path_to PATH /opt/homebrew/bin
fi

prepend_path_to PATH "$HOME"/bin
if [[ -d "$HOME"/.local/bin ]]; then
  prepend_path_to PATH "$HOME"/.local/bin
fi

# shellcheck disable=SC2155
export PS1="\$(if (( \$? )); then printf 'ERROR '; fi)\[\e[48;2;80;38;6;214m\]\$(if [ -n \"\$SSH_TTY\" ]; then printf '%s ' \$(hostname); fi)\[\e[0m\]\[\e[48;3;80;38;5;214m\]\$(parse_git_branch)\[\e[0m\]\n\[\e[48;5;95;38;5;214m\] \$(parse_working_dir) \[\e[0m\] "

pass-file() {
  filename="$1"
  if ! [[ -f "$filename" ]]; then
    echo "pass-file: $filename does not exist" >&2
    return 1
  fi

  shift

  if ! cd "$(dirname "$filename")"; then
    echo "pass-file: failed to cd to $(dirname "$filename")" >&2
    return 1
  fi

  leaf_name="$(basename "$filename")"
  echo "pass-file: Writing file $leaf_name to password-store."
  # shellcheck disable=SC2094
  pass insert -mf "$leaf_name" <"$leaf_name"
}

afzf() {
  ansifilter | fzf
}

gpu() {
  git push -u origin HEAD
}

gar() {
  git fetch --tags --prune origin
  main="$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"
  git rebase origin/"$main"
}

repo-is-dirty() {
  if [[ $(git diff --stat) != '' ]] || [[ -n $(git status --porcelain) ]]; then
    return 0
  else
    return 1
  fi
}

gip() {
  # shellcheck disable=SC2046
  files_to_add=(
    $(find . \
      -type d \( -path ./node_modules -o -path ./.git -o -name build -o -name target \) -prune \
      -o -type f \( -name '*.rs' -o -name '*.py' \) \
      -print
    )
  )
  # Check whether there are files to add (test array length)
  if [[ ${#files_to_add[@]} -gt 0 ]]; then
    git add -- "${files_to_add[@]}"
  else
    echo "gip: No files to add!"
  fi
  git commit -am wip --no-verify
}

gap() {
  message=( "$@" )
  if ! (( ${#message[@]} )) ; then
    message=( updates )
  fi

  if repo-is-dirty; then
    git status -s \
    && git commit -am "${message[*]}" \
    && git push -u origin HEAD \
    && git status -s
  else
    git status
    echo
    echo "gap: Did nothing!"
    echo
  fi
}

on-main-branch() {
  local_branch="$(basename "$(git symbolic-ref HEAD)")"
  remote_main_branch="$(basename "$(git symbolic-ref refs/remotes/origin/HEAD)")"
  if [[ -z "$local_branch" ]] || [[ -z "$remote_main_branch" ]]; then
    echo "on-main-branch: failed to get local and remote branch names!" >&2
    exit 1
  fi

  [[ "$local_branch" == "$remote_main_branch" ]]
}

garp() {
  git fetch --tags --prune origin || return 1

  if on-main-branch; then
    echo "garp: illegal to use garp on main branch!" >&2
    return 1
  fi

  main="$(git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@')"
  git rebase origin/"$main" || return 1
  git push -f || return 1
  git checkout -B "$main" origin/"$main" || return 1
  git merge --ff-only - || return 1
  echo "now run git push"
}

gs() {
  git status -s
}

alias vi="\$EDITOR"
alias rgm='rg --multiline-dotall -U'
alias uuid="python -c \"import uuid;print(uuid.uuid4())\" | tr -d '\n'"
alias activate=". .venv/bin/activate"

dot-ez() {
  dot "$1" -Tpng -Gdpi=300 -o "$1.png" && open "$1.png"
}

export HISTSIZE=5000000
export HISTCONTROL=ignoreboth:erasedups

export EDITOR='nvim' # client -nw -c -a ""'

tail-ide() {
  logs=(
    # "$HOME"/sample.profile 
    "$HOME"/.local/state/pickls/pickls.log
    "$HOME"/.local/state/dmypyls/dmypyls.log
    # "$HOME"/Library/Logs/Zed/Zed.log
    # "$HOME"/.local/state/nvim/lsp.log
    # "$HOME"/bootstrappy.log
  )
  tail -n 0 -f "${logs[@]}" \
    | grep --line-buffered --color=always -E '^|WARNING|WARN|ERROR|CRITICAL|FATAL'
}
tail-pickls() {
  tail -n 0 -f "$HOME"/.local/state/pickls/pickls.log \
    | grep --line-buffered --color=always -E '^|WARNING|WARN|ERROR|CRITICAL|FATAL'

}
tail-dmypyls() {
  tail -n 0 -f "$HOME"/.local/state/dmypyls/dmypyls.log \
    | grep --line-buffered --color=always -E '^|WARNING|WARN|ERROR|CRITICAL|FATAL'
}
tail-nvim() {
  tail -n 0 -f "$HOME"/.local/state/nvim/lsp.log \
    | grep --line-buffered --color=always -E '^|WARNING|WARN|ERROR|CRITICAL|FATAL'
}
on-macos() {
  [[ "$(uname)" = "Darwin" ]]
}

on-linux() {
  [[ "$(uname)" = "Linux" ]]
}

venv() {
  if [[ $1 = '-f' ]]; then
    shift
    rm -rf .venv
  fi
  if [[ -f .venv/pyvenv.cfg ]]; then
    echo "virtualenv already exists [env_dir=$PWD/.venv]"
    return 0
  fi

  if [[ -f .python-version ]]; then
    if command -v pyenv >/dev/null 2>&1; then
      if ! pyenv install -s; then
        echo "pyenv install failed!" >&2
        return 1
      fi
      python="$(pyenv which python)"
      echo "[venv] using python: '$python'"
    else
      echo "pyenv not found, but .python-version exists!" >&2
      return 1
    fi
  else
    python=python3
  fi
  if ! "$python" -mvenv .venv; then
    echo "[venv] failed to create .venv dir" >&2
    return 1
  fi
  if [[ "$(uname)" = "Darwin" ]]; then
    rm .venv/bin/Activate.ps1 .venv/bin/activate.{fi,c}sh
  fi
  .venv/bin/pip install -U pip uv || return 1
  .venv/bin/python -m uv pip install wheel || return 1
  if (( $# )); then
    echo "[venv] running 'uv pip install $*'"
    .venv/bin/python -m uv pip install "$@"
  else
    if ! [[ -d .git ]] && ! [[ -f requirements.txt ]]; then
      echo "Assuming you're in a new project dir. Setting sane defaults..."
      printf "autoimport\nisort\nruff\nmypy\n" >requirements.txt
      .venv/bin/python -m uv pip install -r requirements.txt
      if ! [[ -f .gitignore ]]; then
        echo ".venv" >.gitignore
      fi
      git init .
      git add .
      git commit -am 'initial commit'
    fi
  fi
}

alias p='pstree -s'

if on-macos; then
	bind "set completion-ignore-case on"
	shopt -s cdspell

	# Mac OS
	# set prompt = "%{\033[31m%}[%~] %{\033[0m%}%#"
	alias ls='ls -latr'

	# alias kgs='javaws http://files.gokgs.com/javaBin/cgoban.jnlp'
	# alias simulator='open /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone\ Simulator.app'
	# alias mails='sudo python -m smtpd -n -c DebuggingServer localhost:25'
	alias stopify='pkill -STOP Spotify\ Helper'
	alias startify='pkill -CONT Spotify\ Helper'
elif on-linux; then
  alias pbcopy="xclip -selection clipboard -i"
	alias ls='ls -latr --color'
	shopt -s checkwinsize

	# enable color support of ls and also add handy aliases
	if [ -x /usr/bin/dircolors ]; then
		if test -r ~/.dircolors; then
      eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    fi
	fi

	# colored GCC warnings and errors
	export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

	alias netmon='strace -f -e trace=network -s 10000'
  alias open='xdg-open'
fi

if command -v eza >/dev/null; then
  # eza trumps other ls settings
  alias ls='eza -Bla -s modified'
fi

command -v xmodmap >/dev/null 2>/dev/null && [[ -f "$HOME/xmodmap.file" ]] && xmodmap -v "$HOME/xmodmap.file"

# shellcheck disable=SC2155
command -v rbenv >/dev/null 2>/dev/null && eval "$(rbenv init -)"

# Maybe enable for LLVM fun.
llvm-mode() {
  llvm_dir="/usr/local/opt/llvm"
  [ -x "$llvm_dir/bin/clang" ] || {
    echo "Looks like LLVM is not installed..."
    return 1
  }
  prepend_path_to PATH "$llvm_dir/bin"
  hash -r
  export LDFLAGS="-L$llvm_dir/lib"
  export CPPFLAGS="-L$llvm_dir/include"
  if [ "$(command -v clang)" != "$llvm_dir/bin/clang" ]; then
    echo "WARNING: You are in .llvm-mode but clang was not found in $llvm_dir/bin!"
  else
    clang --version
  fi
}

brew-test() {
  . "$HOME/bin/brew.sh"
  brewtest
}

brew-tags() {
  . "$HOME/bin/brew.sh"
  brewtags
}

newest() {
  unset -v latest
  for file in "$@"; do
    [[ $file -nt $latest ]] && latest=$file
  done
  echo "$latest"
}

after() {
   awk '/'"$1"'/ { seen=1 } { if (seen) print; }'
}

before() {
   awk '/'"$1"'/ { seen=1 } { if (!seen) print; }'
}

# GIT heart FZF
# -------------
# From https://gist.github.com/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

fzf-down() {
  fzf --height 50% --min-height 20 --border --bind ctrl-/:toggle-preview "$@"
}

video-driver() {
  grep "X Driver" /var/log/Xorg.0.log
}

console-setup() {
  sudo dpkg-reconfigure console-setup
}

text-mode() {
  if [[ "$(uname)" == "Linux" ]]; then
    sudo systemctl isolate multi-user.target
  else
    echo "text-mode only works on Linux" >&2
  fi
}

graphical-mode() {
  if [[ "$(uname)" == "Linux" ]]; then
    sudo systemctl isolate graphical.target
  else
    echo "graphical-mode only works on Linux" >&2
  fi
}

agent-with-keys() {
  keys=( "$@" )
  if [[ -z "$SSH_AGENT_PID" ]]; then
    eval "$(ssh-agent)"
    if [[ -n "$SSH_AGENT_PID" ]]; then
      trap 'kill '"$SSH_AGENT_PID" EXIT
    fi
  fi

  ssh-add -D \
    && ssh-add "${keys[@]}" \
    && ssh-add -l

  pkill -f gpg-agent
  args=( )
  if [[ "$(uname)" = "Linux" ]]; then
    pinentry="$(command -v pinentry-curses)"
    if [[ -x "$pinentry" ]]; then
      args+=( --pinentry-program="$pinentry" )
    fi
  fi
  echo "running 'gpg-agent ${args[*]} --daemon"
  gpg-agent "${args[@]}" --daemon
}

logit() {
  touch "$HOME"/notes.md
  nvim "$HOME"/notes.md "+norm G"
}

GPG_TTY="$(tty)"
export GPG_TTY

[[ -f "$HOME/.ghcup/env" ]] && . "$HOME/.ghcup/env" # ghcup-env
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
if [[ -d "$HOME/.ghcup/bin" ]]; then
  export PATH="$PATH:$HOME/.ghcup/bin"
fi

[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash

if [[ -f "$HOME/local.bashrc" ]]; then
  . "$HOME/local.bashrc"
fi

declare -x RUST_SRC_PATH
RUST_SRC_PATH="$(rustc --print sysroot)"/lib/rustlib/src/rust/library/

printf ''
