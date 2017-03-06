export PS1="\[\033[48;5;95;38;5;214m\] \u@\h \[\033[0;38;5;31;48;5;240;22m\] \$git_branch\$git_dirty \[\033[0;38;5;252;48;5;240;1m\]\$PWD \[\033[0;38;5;240;49;22m\]\[\033[0m\] "
export SRC_ROOT=$HOME/src
export TZ=UTC
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
	alias stopify='pkill -STOP Spotify\ Helper'
	alias startify='pkill -CONT Spotify\ Helper'
fi

if [ $platform == 'linux' ]; then
	#bind '"\C-i": menu-complete' 2> /dev/null
	alias ls='ls -G -a -l -tr --color'
	shopt -s histappend
	shopt -s checkwinsize


	# make less more friendly for non-text input files, see lesspipe(1)
	[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

	# set variable identifying the chroot you work in (used in the prompt below)
	if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
		debian_chroot=$(cat /etc/debian_chroot)
	fi

	# set a fancy prompt (non-color, unless we know we "want" color)
	case "$TERM" in
		xterm-color|*-256color) color_prompt=yes;;
	esac

	# uncomment for a colored prompt, if the terminal has the capability; turned
	# off by default to not distract the user: the focus in a terminal window
	# should be on the output of commands, not on the prompt
	force_color_prompt=yes

	if [ -n "$force_color_prompt" ]; then
		if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
		else
		color_prompt=
		fi
	fi

	parse_git_branch() {
		git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1):/'
	}

	if [ "$color_prompt" = yes ]; then
		PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:$(parse_git_branch)\[\033[02;34m\]\w\[\033[00m\] \$ '
	else
		PS1='${debian_chroot:+($debian_chroot)}$(parse_git_branch)\u@\h:\w\$ '
	fi
	unset color_prompt force_color_prompt

	# enable color support of ls and also add handy aliases
	if [ -x /usr/bin/dircolors ]; then
		test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
		alias ls='ls -G -a -l -tr --color'
		#alias dir='dir --color=auto'
		#alias vdir='vdir --color=auto'

		alias grep='grep --color=auto'
		alias fgrep='fgrep --color=auto'
		alias egrep='egrep --color=auto'
	fi

	# colored GCC warnings and errors
	export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

	#alias netmon='strace -f -e trace=network -s 10000'

	# Debian
	#set prompt = "%{\033[32m%}[%~] %{\033[0m%}%#"
	#setenv LS_COLORS 'no=00:fi=00:di=01;33:ln=01;36:pi=40;33:so=40;33:bd=40;33:cd=40;33:ex=01;32:*.sh=01;32:*.pl=01;32:'
	#set color = (ls-F)
	#set term=xterm
	# limit coredumpsize 16000
	# if [[ -f "/usr/local/bin/ssh_proxy_via_bastion" ]]; then
	# 	export GIT_SSH=/usr/local/bin/ssh_proxy_via_bastion
	# fi
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

if [ -f "$HOME/local.bashrc" ]; then
	. $HOME/local.bashrc
fi
