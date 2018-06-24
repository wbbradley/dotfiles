# enable bash completion in interactive shells
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	elif [ -d /usr/local/etc/bash_completion.d ]; then
		for f in /usr/local/etc/bash_completion.d/*; do source $f; done
	fi
fi

parse_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

prompt_prefix() {
	if [ `uname` = 'Linux' ]; then
		echo '\[\033[48;5;92;32;5;214m\] linux \[\033[0m\]'
	else
		echo '\[\033[48;5;88;34;5;214m\] macOS \[\033[0m\]'
	fi
}

export PS1="$(prompt_prefix) \[\033[48;5;95;38;5;214m\] \u@\h \[\033[0;38;5;31;48;5;240;22m\] \[\033[0;38;5;252;48;5;240;1m\] \$(parse_git_branch) \$PWD \[\033[0;38;5;240;49;22m\]\[\033[0m\] "

export SRC_ROOT=$HOME/src
alias vi=vim
alias uuid='python -c "import uuid;print(uuid.uuid4())" | tee | pbcopy'
HISTFILESIZE=5000

shopt -s histappend
man() {
	env \
		LESS_TERMCAP_mb=$(printf "\e[1;31m") \
		LESS_TERMCAP_md=$(printf "\e[1;31m") \
		LESS_TERMCAP_me=$(printf "\e[0m") \
		LESS_TERMCAP_se=$(printf "\e[0m") \
		LESS_TERMCAP_so=$(printf "\e[1;44;33m") \
		LESS_TERMCAP_ue=$(printf "\e[0m") \
		LESS_TERMCAP_us=$(printf "\e[1;32m") \
		man "$@"
}

dbg() {
	echo Running LLDB debugger...
	lldb -o run -- "$@"
}

function nowrap()
{
       printf '\033[?7l'
}

function wrap()
{
       printf '\033[?7h'
}

function dp()
{
	git diff $1^ $1
}

function fup() {
	x=`pwd`; while [ "$x" != "/" ] ; do x=`dirname "$x"`; find "$x" -maxdepth 1 -name $1; done
}

function diff-mine()
{
	git diff `git log --format='%h %ae' | grep -v -e $(git config user.email) | head -n 1 | sed -e "s/\(.*\) .*/\1/"` HEAD
}

function rebase-mine()
{
    git rebase -i `git log --format='%h %ae' | grep -v -e $(git config user.email) | head -n 1 | sed -e "s/\(.*\) .*/\1/"`~
}

function scroll-clear()
{
	clear
	echo -en "\e[3J"
}

function swap()
{
    local TMPFILE=tmp.$$
    mv "$1" $TMPFILE
    mv "$2" "$1"
    mv $TMPFILE "$2"
}

function port()
{
	lsof -n -i4TCP:$1 | grep LISTEN
}

function tree() {
	ls -R | grep ":$" | sed -e 's/:$//' -e 's/[^-][^\/]*\//--/g' -e 's/^/   /' -e 's/-/|/' | grep -v -e pycache -e 'env$'
}

_fab_completion() {
    COMPREPLY=()

    local cur="${COMP_WORDS[COMP_CWORD]}"

    local tasks=$(fab --shortlist 2>/dev/null)
    COMPREPLY=( $(compgen -W "${tasks}" -- ${cur}) )
}
complete -F _fab_completion fab
function acc() {
	find . -type f -amin -$1 | grep -v -e "\.git" -e sass -e node_
}
function mod() {
	find . -type f -mmin -$1 | grep -v -e "\.git" -e sass -e node_ -e "pyc$"
}
function flake() {
       (. env/bin/activate; git diff --name-only | grep "\.py$" | xargs flake8)
       (. env/bin/activate; git diff --cached --name-only | grep "\.py$" | xargs flake8)
}
alias agent='eval `ssh-agent` && ssh-add'

export EDITOR="vim"
export PATH=$PATH:$HOME/bin

platform='unknown'
unamestr=`uname`

if [ "$unamestr" = 'Linux' ]; then
	platform='linux'
elif [ "$unamestr" = 'FreeBSD' ]; then
	platform='freebsd'
elif [ "$unamestr" = 'Darwin' ]; then
	platform='freebsd'
elif [ -d "/c/Windows" ]; then
	platform='windows'
fi

alias venv='. env/bin/activate ; python --version ; pip --version'
alias venvc='virtualenv -p python3 env && . env/bin/activate ; python --version ; pip --version'

wvi () {
	$EDITOR `which $@`;
}

if [ $platform == 'windows' ]; then
	alias ls='ls -G -a -l -tr --color'
fi

if [ $platform == 'freebsd' ]; then
	export PATH="/usr/local/sbin:/usr/local/bin:$PATH"
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
fi

if [ $platform == 'linux' ]; then
	alias ls='ls -G -a -l -tr --color'
	shopt -s histappend
	shopt -s checkwinsize

	# make less more friendly for non-text input files, see lesspipe(1)
	[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

	# enable color support of ls and also add handy aliases
	if [ -x /usr/bin/dircolors ]; then
		test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

		alias grep='grep --color=auto'
		alias fgrep='fgrep --color=auto'
		alias egrep='egrep --color=auto'
	fi

	# colored GCC warnings and errors
	export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

	alias netmon='strace -f -e trace=network -s 10000'
fi

if [ -f "$HOME/local.bashrc" ]; then
	. $HOME/local.bashrc
fi
