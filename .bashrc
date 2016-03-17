export SRC_ROOT=$HOME/src
export TZ=UTC
alias vi=vim
HISTFILESIZE=5000

shopt -s histappend
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
alias dus='du -sk * | sed "s/ /_/g" | sort -n | awk '\''
{ if ($1 < 1024) { output("K", 1) }
  else if ($1 < 1048576) { output("M", 1024) }
  else { output("G", 1048576) }
}
function output(size, div)
{
  printf "%d%s\t%s\n", ($1/div), size, $2
}
'\'''

export EDITOR="vim"
export PATH=$PATH:$HOME/bin

if [ -f $HOME/.git-completion.sh ]; then
	. $HOME/.git-completion.sh
fi

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
alias venvc='virtualenv env && . env/bin/activate ; python --version ; pip --version'

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
fi

if [ $platform == 'linux' ]; then
	bind '"\C-i": menu-complete' 2> /dev/null
	alias ls='ls -G -a -l -tr --color'
	alias netmon='strace -f -e trace=network -s 10000'

	# Debian
	#set prompt = "%{\033[32m%}[%~] %{\033[0m%}%#"
	#setenv LS_COLORS 'no=00:fi=00:di=01;33:ln=01;36:pi=40;33:so=40;33:bd=40;33:cd=40;33:ex=01;32:*.sh=01;32:*.pl=01;32:'
	#set color = (ls-F)
	#set term=xterm
	# limit coredumpsize 16000
	# if [[ -f "/usr/local/bin/ssh_proxy_via_bastion" ]]; then
	# 	export GIT_SSH=/usr/local/bin/ssh_proxy_via_bastion
	# fi
	export PATH=$PATH:$HOME/.local/bin
	ssh-reagent () {
		for agent in /tmp/ssh-*/agent.*; do
			export SSH_AUTH_SOCK=$agent
			if ssh-add -l 2>&1 > /dev/null; then
				echo Found working SSH Agent:
				ssh-add -l
				return
			fi
		done
		echo "Cannot find ssh agent - maybe you should reconnect and forward it?"
	}
fi

export GITAWAREPROMPT=~/.bash/git-aware-prompt
source "${GITAWAREPROMPT}/main.sh"
export PS1="\[\033[0;38;5;231;48;5;31;1m\] \h \[\033[0;38;5;31;48;5;240;22m\] \$git_branch\$git_dirty \[\033[0;38;5;252;48;5;240;1m\]\$PWD \[\033[0;38;5;240;49;22m\]\[\033[0m\] "

if [ -f "$HOME/local.bashrc" ]; then
	. $HOME/local.bashrc
fi
