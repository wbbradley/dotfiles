function fzf-or-grep() {
	if [[ -z "$1" ]] ; then
		fzf
	else
		grep "$@"
	fi
}

function peg() {
	# Usage:
	# peg 
	#   Called with no parameters, it will list the contents of the $HOME/pegged.txt.
	# peg param1 param2 ...
	#   Called with parameters, it will look through all filenames passed
	#   in, check if those files exist, and save the resolved paths to the
	#   pegged.txt file.
	#
	local PEGFILE="$HOME/pegged.txt"
	if [ $# -eq 0 ]; then
		cat "$PEGFILE"
	else
		for f in $@; do
			fullpath=$(realpath "$f")
			if [[ -e "${fullpath}" ]]; then
				if ! grep "$fullpath" "$PEGFILE"; then
					echo $(realpath "$f") >> "$PEGFILE"
				fi
			else
				echo "File ${fullpath} does not seem to exist... ignoring..."
				return 1
			fi
		done
	fi
}

function pegd() {
	# Go to the directory where one of your pegged files lives.
	# Usage
	# peg
	#   Called with no parameters, it will invoke fzf on your pegged.txt
	#   file and allow you to choose a file. It will then `cd` to that
	#   directory.
	# peg params...
	#   Called with params, it will pass them along to grep to filter down
	#   your list of pegged files, and choose the top 1. It will then `cd`
	#   to that directory.
	local chosen=$(peg | fzf-or-grep "$@" | tail -n 1)
	if [[ -n "${chosen}" ]] ; then
		local pegged_dir=$(dirname "${chosen}")
		cd "${pegged_dir:-.}"
	fi
}

function pegvi() {
	# Go to the directory where one of your pegged files lives, and open it in vim.
	# Usage
	# peg
	#   Called with no parameters, it will invoke fzf on your pegged.txt
	#   file and allow you to choose a file. It will then `cd` to that
	#   directory, then open it. Your shell directory will not change.
	# peg params...
	#   Called with params, it will pass them along to grep to filter down
	#   your list of pegged files, and choose the top 1. It will then `cd`
	#   to that directory and open it. Your shell directory will not
	#   change.
	local chosen=$(peg | fzf-or-grep "$@" | tail -n 1)
	if [[ -n "${chosen}" ]] ; then
		local pegged_dir=$(dirname "${chosen}")
		cd "${pegged_dir:-.}"
		vi "${chosen}"
	fi
}
