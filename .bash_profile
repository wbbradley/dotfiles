export SRC_ROOT=$HOME/src

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

if [[ -d "/usr/local/heroku/bin" ]]; then
	export PATH="/usr/local/heroku/bin:$PATH"
fi

if [ -f $HOME/.git-completion.sh ]; then
	. $HOME/.git-completion.sh
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

alias venv='. env/bin/activate'
alias venvc='virtualenv env && . env/bin/activate'

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
	# defaults write com.apple.Xcode XCCodeSenseFormattingOptions -dict BlockSeparator "\n" CaseStatementSpacing ""
	# defaults write com.apple.Xcode PBXPageGuideLocation "79"
	# alias kgs='javaws http://files.gokgs.com/javaBin/cgoban.jnlp'
	# alias simulator='open /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone\ Simulator.app'
	# alias mails='sudo python -m smtpd -n -c DebuggingServer localhost:25'
fi

if [[ $platform == 'linux' ]]; then
	alias ls='ls -G -a -l -tr --color'
	# Debian
	#set prompt = "%{\033[32m%}[%~] %{\033[0m%}%#"
	#setenv LS_COLORS 'no=00:fi=00:di=01;33:ln=01;36:pi=40;33:so=40;33:bd=40;33:cd=40;33:ex=01;32:*.sh=01;32:*.pl=01;32:'
	#set color = (ls-F)
	#set term=xterm
	# limit coredumpsize 16000
	# if [[ -f "/usr/local/bin/ssh_proxy_via_bastion" ]]; then
	# 	export GIT_SSH=/usr/local/bin/ssh_proxy_via_bastion
	# fi
fi


if [[ $platform == 'freebsd' ]]; then
	PYTHON_ROOT=$HOME/Library/Python/2.7
	POWERLINE_ROOT=$PYTHON_ROOT/lib/python/site-packages/powerline
else
	PYTHON_ROOT=$HOME/.local
	POWERLINE_ROOT=$HOME/.local/lib/python2.7/site-packages/powerline
fi

PYTHON_USER_BIN=$PYTHON_ROOT/bin
export PATH=$PATH:$PYTHON_USER_BIN

if [[ -d "$POWERLINE_ROOT" ]]; then
	$PYTHON_USER_BIN/powerline-daemon -q
	. $POWERLINE_ROOT/bindings/bash/powerline.sh
	POWERLINE_COMMAND="$POWERLINE_COMMAND -c ext.shell.theme=default_leftonly"
fi

if [[ -f "$HOME/local.bashrc" ]]; then
	. $HOME/local.bashrc
fi
