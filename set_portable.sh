#!/usr/bin/env bash
if [ -z "$dir0" ]; then
	dir0="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
fi


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
		find $dir_dist -name '__pycache__' -type d | while read line; do
			#echo "Processing file $line"
			rm -rf $line
			fn_stoponerror $? $LINENO
		done
	echo "...done"

	echo "Removing pyc files..."
		find $dir_dist -name '*.pyc' | while read line; do
			#echo "Processing file $line"
			rm -rf $line
			fn_stoponerror $? $LINENO
		done
	echo "...done"
}

fn_fix_path ()
{
	echo "Fixing path in files..."
		echo "  searching for $str_to_find"
		files_to_replace=$(grep -Ilrw $dir_dist -e $str_to_find)
		#fn_stoponerror $? $LINENO
		for f in $files_to_replace
		do
			if test -f "$f"; then
				#echo "processing $f"
				sed -i -e "s,$str_to_find,$dir_fixed,g" $f
				if [[ -L "$f" ]]; then
					echo "skipping link ($f)"
					continue
				fi
			fi
		done
	echo "...done"
}

if [ "$script_parent" == "builder" ]; then
	echo "called from builder"
	dir_fixed="/run_fix_portable.sh"
	dir_dist="$product_release_install_dir"
	str_to_find=$dir_dist
	fn_remove_cache
	fn_fix_path
else
	echo "called directly"
	dir_fixed="$dir0"
	dir_dist="$dir0"
	. "$dir0/portable_path.sh"
	fn_stoponerror $? $LINENO
	str_to_find=$portable_path
	if [ "$portable_path" == "$dir0" ]; then
		echo "portable path is correct ($portable_path=$dir0)"
	else
		echo "portable path is wrong, fixing..."
		fn_remove_cache
		fn_fix_path
	fi
fi


