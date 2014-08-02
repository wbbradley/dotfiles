#!/bin/bash

# To run this you must first run
# brew install figlet

function status_report() {
	figlet -w 200 $1
	git status
}

function status() {
	pushd $1 > /dev/null
	git status | grep "diverged\|not staged\|branch is ahead\|to be committed" > /dev/null && status_report $1
	popd > /dev/null
}

find . -type d | sort | grep "/\.git$" | sed -e "s/\/\.git$//" | sed -e "s/^\.\///" | while read -r git_dir ; do
	status $git_dir
done
