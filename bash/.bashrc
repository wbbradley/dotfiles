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

parse_working_dir() {
	echo `pwd` | sed s%`echo $HOME`%~%
}

export PS1="\$(if [ \$? != 0 ]; then echo '\[\033[47;5;88;34;5;1m\] ERROR \[\033[0m\]'; fi) \[\033[48;5;95;38;5;214m\] \u \[\033[0;38;5;31;48;5;240;22m\] \[\033[0;38;5;252;48;5;240;1m\] \$(parse_git_branch) \$(parse_working_dir) \[\033[0;38;5;240;49;22m\]\[\033[0m\] "

export SRC_ROOT=$HOME/src
alias vi=vim
alias uuid='python -c "import uuid;print(uuid.uuid4())" | tee | pbcopy'
HISTFILESIZE=15000

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
	shopt -s checkwinsize

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

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
