. $HOME/.bashrc
df -h .

export GITAWAREPROMPT=~/.bash/git-aware-prompt
source "${GITAWAREPROMPT}/main.sh"

export PS1="\[\033[48;5;95;38;5;214m\] \u@\h \[\033[0;38;5;31;48;5;240;22m\] \$git_branch\$git_dirty \[\033[0;38;5;252;48;5;240;1m\]\$PWD \[\033[0;38;5;240;49;22m\]\[\033[0m\] "