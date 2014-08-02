export SRC_ROOT=$HOME/src
export MARKPATH=$HOME/.marks
function jump {
    cd -P $MARKPATH/$1 2>/dev/null || echo "No such mark: $1"
}
function mark {
    mkdir -p $MARKPATH; ln -s $(pwd) $MARKPATH/$1
}
function unmark { 
    rm -i $MARKPATH/$1 
}
function marks {
    ls -l $MARKPATH | sed 's/  / /g' | cut -d' ' -f9- && echo
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

_fab_completion() {
    COMPREPLY=()

    local cur="${COMP_WORDS[COMP_CWORD]}"

    local tasks=$(fab --shortlist 2>/dev/null)
    COMPREPLY=( $(compgen -W "${tasks}" -- ${cur}) )
}
complete -F _fab_completion fab

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

alias ms=marks
alias m=mark
alias c=jump
alias j=jump

export EDITOR="vim"

mymake()
{
	make -j10 $1
}

alias make=mymake

export PATH=$PATH:$HOME/bin

if [[ -d "/usr/local/heroku/bin" ]]; then
	export PATH="/usr/local/heroku/bin:$PATH"
fi

if [ -f ~/.git-completion.sh ]; then
	. ~/.git-completion.sh
fi

platform='unknown'
unamestr=`uname`
if [[ "$unamestr" == 'Linux' ]]; then
	platform='linux'
elif [[ "$unamestr" == 'FreeBSD' ]]; then
	platform='freebsd'
elif [[ "$unamestr" == 'Darwin' ]]; then
	platform='freebsd'
elif [ -d "/c/Windows" ]; then
	platform='windows'
fi

alias venv='source env/bin/activate'
wvi () { $EDITOR `which $@`; }

if [[ $platform == 'windows' ]]; then
	alias ls='ls -G -a -l -tr --color'
fi

if [[ $platform == 'freebsd' ]]; then
	bind "set completion-ignore-case on"
	shopt -s cdspell

	# Mac OS
	# set prompt = "%{\033[31m%}[%~] %{\033[0m%}%#"
	alias ls='ls -G -a -l -tr'
	defaults write com.apple.finder AppleShowAllFiles true
	defaults write com.apple.Xcode XCCodeSenseFormattingOptions -dict BlockSeparator "\n" CaseStatementSpacing ""
	defaults write com.apple.Xcode PBXPageGuideLocation "79"
	alias kgs='javaws http://files.gokgs.com/javaBin/cgoban.jnlp'
	alias venvc="virtualenv env && source env/bin/activate"
	alias simulator='open /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone\ Simulator.app'
	alias mails='sudo python -m smtpd -n -c DebuggingServer localhost:25'
	fvi () { vi `f $@`; }
	git-get () { git show $1:$2 > $2; }
	export PGDATA=/usr/local/var/postgres

	DULL=0
	BRIGHT=1

	FG_BLACK=30
	FG_RED=31
	FG_GREEN=32
	FG_YELLOW=33
	FG_BLUE=34
	FG_VIOLET=35
	FG_CYAN=36
	FG_WHITE=37

	FG_NULL=00

	BG_BLACK=40
	BG_RED=41
	BG_GREEN=42
	BG_YELLOW=43
	BG_BLUE=44
	BG_VIOLET=45
	BG_CYAN=46
	BG_WHITE=47

	BG_NULL=00

	##
	# ANSI Escape Commands
	##
	ESC="\033"
	NORMAL="\[$ESC[m\]"
	RESET="\[$ESC[${DULL};${FG_WHITE};${BG_NULL}m\]"

	##
	# Shortcuts for Colored Text ( Bright and FG Only )
	##

	# DULL TEXT

	BLACK="\[$ESC[${DULL};${FG_BLACK}m\]"
	RED="\[$ESC[${DULL};${FG_RED}m\]"
	GREEN="\[$ESC[${DULL};${FG_GREEN}m\]"
	YELLOW="\[$ESC[${DULL};${FG_YELLOW}m\]"
	BLUE="\[$ESC[${DULL};${FG_BLUE}m\]"
	VIOLET="\[$ESC[${DULL};${FG_VIOLET}m\]"
	CYAN="\[$ESC[${DULL};${FG_CYAN}m\]"
	WHITE="\[$ESC[${DULL};${FG_WHITE}m\]"

	# BRIGHT TEXT
	BRIGHT_BLACK="\[$ESC[${BRIGHT};${FG_BLACK}m\]"
	BRIGHT_RED="\[$ESC[${BRIGHT};${FG_RED}m\]"
	BRIGHT_GREEN="\[$ESC[${BRIGHT};${FG_GREEN}m\]"
	BRIGHT_YELLOW="\[$ESC[${BRIGHT};${FG_YELLOW}m\]"
	BRIGHT_BLUE="\[$ESC[${BRIGHT};${FG_BLUE}m\]"
	BRIGHT_VIOLET="\[$ESC[${BRIGHT};${FG_VIOLET}m\]"
	BRIGHT_CYAN="\[$ESC[${BRIGHT};${FG_CYAN}m\]"
	BRIGHT_WHITE="\[$ESC[${BRIGHT};${FG_WHITE}m\]"

	# REV TEXT as an example
	REV_CYAN="\[$ESC[${DULL};${BG_WHITE};${BG_CYAN}m\]"
	REV_RED="\[$ESC[${DULL};${FG_YELLOW}; ${BG_RED}m\]"

	PROMPT_COMMAND='export ERR=$?'

	PS1="${BRIGHT_RED}[\w]${NORMAL}\$ ${RESET}"
fi

if [[ $platform == 'linux' ]]; then
	alias ls='ls -G -a -l -tr --color'
	# Debian
	#set prompt = "%{\033[32m%}[%~] %{\033[0m%}%#"
	#setenv LS_COLORS 'no=00:fi=00:di=01;33:ln=01;36:pi=40;33:so=40;33:bd=40;33:cd=40;33:ex=01;32:*.sh=01;32:*.pl=01;32:'
	#set color = (ls-F)
	#set term=xterm
	# limit coredumpsize 16000
	if [[ -f "/usr/local/bin/ssh_proxy_via_bastion" ]]; then
		export GIT_SSH=/usr/local/bin/ssh_proxy_via_bastion
	fi
fi

if [[ -d "$(echo $HOME/src/powerline-shell)" ]]; then
	function _update_ps1() {
		export PS1="$($HOME/src/powerline-shell/powerline-shell.py $?)"
	}
	export PROMPT_COMMAND="_update_ps1"
fi

if [[ -f "$HOME/local.bashrc" ]]; then
	source $HOME/local.bashrc
fi

if [[ -f "/usr/libexec/java_home" ]]; then
	export JAVA_HOME=`/usr/libexec/java_home` 
fi

export PATH=/usr/local/sbin:$PATH
