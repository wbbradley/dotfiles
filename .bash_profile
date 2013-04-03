echo "------"
bind "set completion-ignore-case on"

shopt -s cdspell

alias ssh-dev='ssh will.thefundersclub.com'

export SRC_ROOT=$HOME/src

mymake()
{
	make -j10 $1
}

alias make=mymake

export PATH=/usr/local/bin:$PATH:/usr/local/share/python:$HOME/bin

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

if [[ $platform == 'windows' ]]; then
	alias ls='ls -G -a -l -tr --color'
fi

if [[ $platform == 'freebsd' ]]; then
	# Mac OS
	# set prompt = "%{\033[31m%}[%~] %{\033[0m%}%#"
	alias ls='ls -G -a -l -tr'
	defaults write com.apple.Xcode XCCodeSenseFormattingOptions -dict BlockSeparator "\n" CaseStatementSpacing ""
	defaults write com.apple.Xcode PBXPageGuideLocation "79"
	alias crontab='env VIM_CRONTAB=true crontab -e'
	alias kgs='javaws http://files.gokgs.com/javaBin/cgoban.jnlp'
	alias venv='source env/bin/activate'
	export PGDATA=/usr/local/var/postgres
	if [ -d "/Library/Java/Home" ]; then
		export JAVA_HOME=/Library/Java/Home
	fi
fi

if [[ $platform == 'linux' ]]; then
	alias ls='ls -G -a -l -tr --color'
	# Debian
	#set prompt = "%{\033[32m%}[%~] %{\033[0m%}%#"
	#setenv LS_COLORS 'no=00:fi=00:di=01;33:ln=01;36:pi=40;33:so=40;33:bd=40;33:cd=40;33:ex=01;32:*.sh=01;32:*.pl=01;32:'
	#set color = (ls-F)
	#set term=xterm
	# limit coredumpsize 16000
fi

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

if [[ -f "local.bashrc" ]]; then
	source local.bashrc
fi

