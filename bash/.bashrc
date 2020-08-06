# vim: ft=sh.bash
[[ $- != *i* ]] && return

# enable bash completion in interactive shells
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    # shellcheck disable=SC1090,SC1091
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    # shellcheck disable=SC1090,SC1091
    . /etc/bash_completion
  elif [ -d /usr/local/etc/bash_completion.d ]; then
    # shellcheck disable=SC1090,SC1091
    for f in /usr/local/etc/bash_completion.d/*; do . "$f"; done
  fi
fi

# shellcheck disable=SC1090
. "$HOME/bin/utils.sh"

export PS1="\$(if [ \$? != 0 ]; then echo '\[\033[47;5;88;34;5;1m\] ERROR \[\033[0m\]'; fi) \[\033[48;5;95;38;5;214m\] \u \[\033[0;38;5;31;48;5;240;22m\] \[\033[0;38;5;252;48;5;240;1m\] \$(parse_git_branch) \$(parse_working_dir) \[\033[0;38;5;240;49;22m\]\[\033[0m\] "

# export SRC_ROOT=$HOME/src
alias vi=vim
alias uuid="python -c \"import uuid;print(uuid.uuid4())\" | tr -d '\n' | pbcopy"
function mydot() {
  dot "$1" -Tpng -Gdpi=300 -o "$1.png" && open "$1.png"
}

HISTFILESIZE=15000

shopt -s histappend

export EDITOR="vim"

platform='unknown'
unamestr="$(uname)"

if [ "$unamestr" = 'Linux' ]; then
	platform='linux'
  alias pbcopy="xclip -selection clipboard -i"
elif [ "$unamestr" = 'FreeBSD' ]; then
	platform='freebsd'
elif [ "$unamestr" = 'Darwin' ]; then
	platform='freebsd'
elif [ -d "/c/Windows" ]; then
	platform='windows'
fi

alias venv='. env/bin/activate ; python --version ; pip --version'
alias venvc='virtualenv -p python3 env && . env/bin/activate ; python --version ; pip --version'

if [ $platform == 'windows' ]; then
	alias ls='ls -G -a -l -tr --color'
fi

if [ $platform = 'freebsd' ]; then
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
	alias grep='grep --color'
elif [ $platform == 'linux' ]; then
	alias ls='ls -G -a -l -tr --color'
	shopt -s checkwinsize

	# enable color support of ls and also add handy aliases
	if [ -x /usr/bin/dircolors ]; then
		if test -r ~/.dircolors; then
      eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    fi

		alias grep='grep --color=auto'
		alias fgrep='fgrep --color=auto'
		alias egrep='egrep --color=auto'
	fi

	# colored GCC warnings and errors
	export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

	alias netmon='strace -f -e trace=network -s 10000'
fi

if [ -f "$HOME/local.bashrc" ]; then
  # shellcheck disable=SC1090
  . "$HOME/local.bashrc"
fi

alias chase='pass chase.com -c && explore-to https://www.chase.com/'
alias amex='pass Amex-Personal -c && explore-to https://www.americanexpress.com/'
alias wells='pass Wells-Fargo -c && explore-to https://www.wellsfargo.com/'
alias fidelity='pass Fidelity -c && explore-to https://www.fidelity.com/'
alias stockplanconnect='pass stockplanconnect.com-morganstanley -c && explore-to https://stockplanconnect.morganstanley.com/'
alias retirementplans='pass retirementplans.vanguard.com -c && explore-to https://retirementplans.vanguard.com/'
alias my.vanguardplan.com='pass my.vanguardplan.com -c && explore-to https://my.vanguardplan.com/'

# shellcheck disable=SC1090
[ -f ~/.fzf.bash ] && . ~/.fzf.bash

[[ -f "${HOME}/xmodmap.file" ]] && xmodmap -v "${HOME}/xmodmap.file"

# shellcheck disable=SC2155
export RUBY_CONFIGURE_OPTS="--with-openssl-dir=$(brew --prefix openssl@1.1)"
(command -v rbenv 1>/dev/null 2>/dev/null) && eval "$(rbenv init -)"
export NVM_DIR="$HOME/.nvm"

# Maybe enable for LLVM fun.
function llvm-mode() {
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

function brew-test() {
  . "$HOME/bin/brew.sh"
  brewtest
}

function brew-tags() {
  . "$HOME/bin/brew.sh"
  brewtags
}

function ctags-ruby() {
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

prepend_path_to PATH "/usr/local/bin"
