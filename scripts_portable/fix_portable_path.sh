#!/usr/bin/env bash

fix_portable_path0="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"


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

fn_remove_cache ()
{
	#remove pycache dirs
	echo "Removing pycache dirs..."
		find $path_to_binaries -name '__pycache__' -type d | while read line; do
			#echo "Processing file $line"
			rm -rf $line
			fn_stoponerror $? $LINENO
		done
	echo "...done"

	echo "Removing pyc files..."
		find $path_to_binaries -name '*.pyc' | while read line; do
			#echo "Processing file $line"
			rm -rf $line
			fn_stoponerror $? $LINENO
		done
	echo "...done"
}

fn_fix_path ()
{
	echo "Fixing path in files..."
		files_to_replace=$(grep -Ilrw $path_to_binaries -e $path_portable_old)
		echo "  searching for string '$path_portable_old'"
		#fn_stoponerror $? $LINENO
		for f in $files_to_replace
		do
			if test -f "$f"; then
				echo "  processing $f"
				sed -i -e "s,$path_portable_old,$path_portable_new,g" $f
				if [[ -L "$f" ]]; then
					echo "  skipping link ($f)"
					continue
				fi
			fi
		done
	echo "...done"
}

if [ "$script_parent" == "builder" ]; then
	echo "called from builder, reseting path to initial..."
	path_to_binaries="$product_release_install_dir"
	. "$path_to_binaries/portable_path.sh"
	fn_stoponerror $? $LINENO
	source $fix_portable_path0/settings.sh
	fn_stoponerror $? $LINENO
	path_portable_new="$settings_path_portable_initial"
	path_portable_old=$portable_path
	echo "\$path_portable_new = $path_portable_new"
	fn_remove_cache
	fn_fix_path
else
	echo "called directly"
	source $fix_portable_path0/settings.sh
	fn_stoponerror $? $LINENO
	path_to_binaries="$fix_portable_path0"
	. "$path_to_binaries/portable_path.sh"
	fn_stoponerror $? $LINENO
	path_portable_new="$fix_portable_path0"
	path_portable_old=$portable_path
	if [ "$path_portable_old" == "$path_portable_new" ]; then
		echo "portable path is correct ($portable_path)"
	else
		echo "portable path is wrong, fixing..."
		fn_remove_cache
		fn_fix_path
	fi	
fi


