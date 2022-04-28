# vim: ft=bash
# shellcheck disable=SC1090,SC1091,SC2207
[[ $- != *i* ]] && return

export RIPGREP_CONFIG_PATH="$HOME/.ripgreprc"
export FZF_DEFAULT_COMMAND="rg --files --iglob '*' --iglob '!*.swp' --iglob '.*' --iglob '!.*.swp' --iglob '!*.pyc' --iglob '!.git' --iglob '!node_modules' --iglob '!.*env/'"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  elif [ -d /usr/local/etc/bash_completion.d ]; then
    for f in /usr/local/etc/bash_completion.d/*; do . "$f"; done
  fi
fi


_ssh() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts=$(grep '^Host' ~/.ssh/config ~/.ssh/config.d/* 2>/dev/null | grep -v '[?*]' | cut -d ' ' -f 2-)

    COMPREPLY=( $(compgen -W "$opts" -- "${cur}") )
    return 0
}
complete -F _ssh ssh

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

# shellcheck disable=SC2155
if command -v yum >/dev/null; then
  export PS1="\h \u \w "
else
  export PS1="\$(
    if [ \$? != 0 ]; then
      bgfgx6 e6 39 46 e9 c4 6a
      echo ' ERROR \[\033[0m\]'
    fi
    )\$(show-env-vars)$(host_color) \h \[\033[0;38;5;31;48;5;240;22m\] \[\033[0;38;5;252;48;5;240;1m\] \$(parse_git_branch)\$(parse_working_dir) \[\033[0;38;5;240;49;22m\033[0m\] "
fi

alias gar='git fetch && git rebase origin/master'
alias vi=vim
alias rgm='rg --multiline-dotall -U'
alias uuid="python -c \"import uuid;print(uuid.uuid4())\" | tr -d '\n' | pbcopy"
mydot() {
  dot "$1" -Tpng -Gdpi=300 -o "$1.png" && open "$1.png"
}

HISTSIZE=50000
shopt -s histappend
export HISTCONTROL=ignoreboth:erasedups

export EDITOR="vim"

on-macos() {
  [[ "$(uname)" = "Darwin" ]]
}

on-linux() {
  [[ "$(uname)" = "Linux" ]]
}

alias venv='. env/bin/activate ; python --version ; pip --version'
alias p='pstree -s'

if on-macos; then
  append_path_to PATH /usr/local/bin /usr/local/sbin
	bind "set completion-ignore-case on"
	shopt -s cdspell

	# Mac OS
	# set prompt = "%{\033[31m%}[%~] %{\033[0m%}%#"
	alias ls='ls -G -a -l -tr'

	# alias kgs='javaws http://files.gokgs.com/javaBin/cgoban.jnlp'
	# alias simulator='open /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone\ Simulator.app'
	# alias mails='sudo python -m smtpd -n -c DebuggingServer localhost:25'
	alias stopify='pkill -STOP Spotify\ Helper'
	alias startify='pkill -CONT Spotify\ Helper'
elif on-linux; then
  alias pbcopy="xclip -selection clipboard -i"
	alias ls='ls -G -a -l -tr --color'
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
fi

if [[ -f "$HOME/local.bashrc" ]]; then
  . "$HOME/local.bashrc"
fi

alias chase='pass chase -c && explore-to https://www.chase.com/'
alias amex='pass Amex-Personal -c && explore-to https://www.americanexpress.com/'
alias wells='pass Wells-Fargo -c && explore-to https://www.wellsfargo.com/'
alias fidelity='pass Fidelity -c && explore-to https://www.fidelity.com/'
alias stockplanconnect='pass stockplanconnect.com-morganstanley -c && explore-to https://stockplanconnect.morganstanley.com/'
alias retirementplans='pass retirementplans.vanguard.com -c && explore-to https://retirementplans.vanguard.com/'
alias my.vanguardplan.com='pass my.vanguardplan.com -c && explore-to https://my.vanguardplan.com/'

[[ -f "$HOME/xmodmap.file" ]] && xmodmap -v "$HOME/xmodmap.file"

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

ctags-ruby() {
  gems_tags=gems.tags
  local_tags=local.tags
  if [ Gemfile -nt "$gems_tags" ] || [ Gemfile.lock -nt "$gems_tags" ]; then
    # Rebuild tags for gems
    echo "Rebuilding tags for Gems..."
    ctags-ruby-core \
      -f "$gems_tags" \
      "$(gem environment gemdir)"/gems/*/lib
  fi
  echo "Rebuilding tags for $PWD..."
  ctags-ruby-core -f local.tags .
  sort "$gems_tags" "$local_tags" \
    > tags
}

ctags-ruby-core() {
  # check that ctags version is correct
  ctags --version >/dev/null 2>&1 || {
    echo "ctags not found or too old." 1>&2
    return 1
  }

  ctags -R \
    --tag-relative=yes \
    --totals=yes \
    --extra=+f \
    --fields=+iaS \
    --exclude=*.md \
    --exclude=db \
    --exclude=docs \
    --exclude=log \
    --exclude=node_modules \
    --exclude=public \
    --exclude=tmp \
    --exclude=vendor \
    --langdef=coffee \
    --langmap=coffee:.coffee \
    --regex-coffee='/[ \t]*class ([A-Za-z.]+)( extends [A-Za-z.]+)?$/\1/c,class/' \
    --regex-coffee='/[ \t]*@?([A-Za-z.]+):.*[-=]>.*$/\1/f,function/' \
    --regex-coffee='/[ \t]*([A-Za-z.]+)[ \t]+=.*[-=]>.*$/\1/f,function/' \
    --langdef=js \
    --langmap=js:.js \
    --regex-js='/(,|(;|^)[ \t]*(var|let|([A-Za-z_$][A-Za-z0-9_$.]+\.)*))[ \t]*([A-Za-z0-9_$]+)[ \t]*=[ \t]*\{/\5/,object/' \
    --regex-js='/(,|(;|^)[ \t]*(var|let|([A-Za-z_$][A-Za-z0-9_$.]+\.)*))[ \t]*([A-Za-z0-9_$]+)[ \t]*=[ \t]*function[ \t]*\(/\5/,function/' \
    --regex-js='/function[ \t]+([A-Za-z0-9_$]+)[ \t]*\([^)]*\)/\1/,function/' \
    --regex-js='/(,|^)[ \t]*([A-Za-z_$][A-Za-z0-9_$]+)[ \t]*:[ \t]*\{/\2/,object/' \
    --regex-js='/(,|^)[ \t]*([A-Za-z_$][A-Za-z0-9_$]+)[ \t]*:[ \t]*function[ \t]*\(/\2/,function/' \
    --regex-ruby='/^[ \t]*scope[ \t]*:([a-zA-Z0-9_]+)/\1/s,scopes/' \
    --regex-ruby='/^[ \t]*has_many[ \t]*:([a-zA-Z0-9_]+)/\1/s,scopes/' \
    --regex-ruby='/^[ \t]*has_and_belongs_to_many[ \t]*:([a-zA-Z0-9_]+)/\1/s,scopes/' \
    --regex-ruby='/^[ \t]*belongs_to[ \t]*:([a-zA-Z0-9_]+)/\1/s,scopes/' \
    --regex-ruby='/^[ \t]*attr_reader[[:space:]]*:([a-zA-Z0-9_]+)/\1/s,function/' \
    --regex-ruby='/^[ \t]*([A-Z_]+)/\1/N,constants/' \
    --regex-ruby='/.*alias(_method)?[[:space:]]+:([[:alnum:]_=!?]+),?[[:space:]]+:([[:alnum:]_=!]+)/\2/,function/' \
    --regex-ruby='/^[ \t]*class[ \t]*([A-Za-z:_]+).*$/\1/c,class/' \
    "$@"
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

_gf() {
  is_in_git_repo || return
  git -c color.status=always status --short |
  fzf-down -m --ansi --nth 2..,.. \
    --preview '(git diff --color=always -- {-1} | sed 1,4d; cat {-1})' |
  cut -c4- | sed 's/.* -> //'
}

_gb() {
  is_in_git_repo || return
  git branch -a --color=always | grep -v '/HEAD\s' | sort |
  fzf-down --ansi --multi --tac --preview-window right:70% \
    --preview 'git log --oneline --graph --date=short --color=always --pretty="format:%C(auto)%cd %h%d %s" $(sed s/^..// <<< {} | cut -d" " -f1)' |
  sed 's/^..//' | cut -d' ' -f1 |
  sed 's#^remotes/##'
}

_gt() {
  is_in_git_repo || return
  git tag --sort -version:refname |
  fzf-down --multi --preview-window right:70% \
    --preview 'git show --color=always {}'
}

_gh() {
  is_in_git_repo || return
  git log --date=short --format="%C(green)%C(bold)%cd %C(auto)%h%d %s (%an)" --graph --color=always |
  fzf-down --ansi --no-sort --reverse --multi --bind 'ctrl-s:toggle-sort' \
    --header 'Press CTRL-S to toggle sort' \
    --preview 'grep -o "[a-f0-9]\{7,\}" <<< {} | xargs git show --color=always' |
  grep -o "[a-f0-9]\{7,\}"
}

_gr() {
  is_in_git_repo || return
  git remote -v | awk '{print $1 "\t" $2}' | uniq |
  fzf-down --tac \
    --preview 'git log --oneline --graph --date=short --pretty="format:%C(auto)%cd %h%d %s" {1}' |
  cut -d$'\t' -f1
}

_gs() {
  is_in_git_repo || return
  git stash list | fzf-down --reverse -d: --preview 'git show --color=always {1}' |
  cut -d: -f1
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

prepend_path_to PATH "/usr/local/bin"
prepend_path_to PATH "$HOME/bin"
[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env" # ghcup-env
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && {
  export NVM_DIR="$HOME/.nvm"
  \. "$NVM_DIR/nvm.sh"  # This loads nvm
}

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash
printf ''
