# vim: ft=sh.bash
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

. "$HOME/bin/utils.sh"

export PS1="\$(if [ \$? != 0 ]; then echo '\[\033[47;5;88;34;5;1m\] ERROR \[\033[0m\]'; fi) \[\033[48;5;95;38;5;214m\] \u \[\033[0;38;5;31;48;5;240;22m\] \[\033[0;38;5;252;48;5;240;1m\] \$(parse_git_branch) \$(parse_working_dir) \[\033[0;38;5;240;49;22m\]\[\033[0m\] "

# export SRC_ROOT=$HOME/src
alias vi=vim
alias uuid="python -c \"import uuid;print(uuid.uuid4())\" | tr -d '\n' | pbcopy"
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
