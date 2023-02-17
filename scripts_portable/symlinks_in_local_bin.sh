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
	path_file=$1
	path_symlink=$2
	ln -sf $path_file $path_symlink
	fn_stoponerror $? $LINENO
}

fn_link_files ()
{
	for file in ${files[@]};
	do
		if test -f "$file"; then
			echo "creating symlink for $file"
			fn_link "$dir0/$file" "$HOME/.local/bin/$file"
			fn_stoponerror $? $LINENO
		fi
	done
}
fn_unlink_files ()
{
	for file in ${files[@]};
	do
		if test -f "$path_local_bin/$file"; then
			echo "deleting link $file"
			rm "$path_local_bin/$file"
			fn_stoponerror $? $LINENO
		fi
	done
}

source settings.sh
fn_stoponerror $? $LINENO
files=("sallectapip$settings_python_version_short" "sallectapython$settings_python_version_short")
path_local_bin="$HOME/.local/bin"

arg_1=$1

if [ "$arg_1" == "link" ]; then 
	fn_link_files
elif [ "$arg_1" == "unlink" ]; then 
	fn_unlink_files
else
	echo "Wrong arguments."
	    printf "
Usage:
	link	- create links in $path_local_bin;
	unlink	- delete links in $path_local_bin.	
\n\n"
fi


