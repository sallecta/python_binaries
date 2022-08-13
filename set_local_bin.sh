dir0="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

fn_stoponerror ()
{
	# Usage:
	# fn_stoponerror $? $LINENO
	error_code=$1
	line=$2
	if [ $error_code -ne 0 ]; then
		printf "\n"$line": error ["$error_code"]\n\n"
		exit $error_code
	fi
}

fn_link ()
{
	path2file=$1
	path2symlink=$2
	ln -sf $path2file $path2symlink
	fn_stoponerror $? $LINENO
}

fn_link_files ()
{
	files=$(ls sallecta-*)
	for f in $files
	do
		if test -f "$f"; then
			echo "processing $f"
			fn_link "$dir0/$f" "$HOME/.local/bin/$f"
			fn_stoponerror $? $LINENO
		fi
	done
}
fn_unlink_files ()
{
	files=$(ls sallecta-*)
	dir_local_bin="$HOME/.local/bin"
	for f in $files
	do
		if test -f "$dir_local_bin/$f"; then
			echo "processing $f"
			rm "$dir_local_bin/$f"
			fn_stoponerror $? $LINENO
		fi
	done
}

arg_1=$1
if [ "$arg_1" = "link" ]; then 
	fn_link_files
elif [ "$arg_1" = "unlink" ]; then 
	fn_unlink_files
else
	echo "wrong args"
fi


