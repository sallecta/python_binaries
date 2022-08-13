#!/usr/bin/env bash

fn_stoponerror ()
{
	# Usage:
	# fn_stoponerror $? $LINENO
	error_code=$1
	line=$2
	if [ $error_code -ne 0 ]; then
		printf "\n"$line": error ["$error_code"]\n\n"
		exit $error_code
	else
		printf "\n"$line": succsess\n\n"
	fi
}

fn_print_usage ()
{
    printf "
Usage:
	clean	- delete all builded and installed files;
	make 64	- configure, make and install (portable) 64 bit $product_src_name;
	deploy 64	- deploy 64 bit portable in tar.gz.	
\n\n"
}

dir0="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
script_parent="builder"

arg_1=$1
arg_2=$2
if [ "$arg_2" = "32" ]; then 
	product_architecture="i686-linux-gnu"

elif [ "$arg_2" = "64" ]; then
	product_architecture="x86_64-linux-gnu"
fi

product_src_name="Python-3.10.6"
product_src_dir="$dir0/src"
product_release_name="$product_src_name""_$product_architecture""_build"
product_install_dir="$dir0/install"
product_release_install_dir="$product_install_dir/$product_release_name"
product_tar_archive_name="$product_release_name"".tar.gz"


action=""

if [ "$arg_1" = "clean" ] && [ "$arg_2" = "" ]; then
	action="clean"
	
elif [ "$arg_1" = "make" ] && [ "$arg_2" = "64" ]; then
	action="make64"
	
elif [ "$arg_1" = "deploy" ] && [ "$arg_2" = "64" ]; then
	action="deploy64"
	
else
	printf "\n\nWrong arguments: ["$arg_1"], ["$arg_2"].\n\n"
	fn_print_usage
	exit 1
fi

printf "\n"$LINENO": Checking root directory\n"
cd $dir0
fn_stoponerror $? $LINENO

if [ "$action" = "clean" ]; then
	printf "\n"$LINENO": Checking install directories\n"
	ls "$product_src_dir"   "$product_install_dir"
	fn_stoponerror $? $LINENO
	
	printf "\n"$LINENO": Removing src and install directories\n"
	rm -r  "$product_src_dir"   "$product_install_dir"
	fn_stoponerror $? $LINENO
	
elif [ "$action" = "make64" ]; then 
	printf "\n"$LINENO": Creating product source directory [$product_src_dir]\n"
	mkdir -p "$product_src_dir"
	fn_stoponerror $? $LINENO
	
	printf "\n"$LINENO": Extracting product source [$product_src_name]\n"
	tar -xf "$dir0/distr/"$product_src_name".tar.xz" -C "$product_src_dir"
	fn_stoponerror $? $LINENO
	
	printf "\n"$LINENO": Creating installation directory [$product_release_install_dir]\n"
	mkdir -p $product_release_install_dir
	fn_stoponerror $? $LINENO
	
	printf "\n"$LINENO": Entering product source directory [$product_src_name]\n"
	cd "$product_src_dir/"$product_src_name
	fn_stoponerror $? $LINENO
	
	printf "\n"$LINENO": Configuring $product_release_name\n"
	./configure --prefix=$product_release_install_dir

	fn_stoponerror $? $LINENO
	
	printf "\n"$LINENO": Making $product_release_name\n"
	make
	fn_stoponerror $? $LINENO
	
	printf "\n"$LINENO": Installing $product_release_name to [$product_release_install_dir]\n"
	make install
	fn_stoponerror $? $LINENO
	
elif  [ "$action" = "deploy64" ]; then 
	
	echo "Registering initial portable path"
	echo "portable_path=/run_fix_portable.sh">$product_release_install_dir/portable_path.sh
	fn_stoponerror $? $LINENO
	chmod u+x $product_release_install_dir/portable_path.sh
	fn_stoponerror $? $LINENO
	
	echo "Copying setup scripts"
	cp $dir0/set_*.sh $product_release_install_dir/
	fn_stoponerror $? $LINENO
	chmod u+x $product_release_install_dir/set_*.sh
	fn_stoponerror $? $LINENO
	
	echo "Copying launchers"
	cp $dir0/sallecta-* $product_release_install_dir/
	fn_stoponerror $? $LINENO
	chmod u+x $product_release_install_dir/sallecta-*
	fn_stoponerror $? $LINENO
	
	. $dir0/set_portable.sh
	fn_stoponerror $? $LINENO
	
	printf "\n"$LINENO": Packing ["$product_release_install_dir"] to ["$product_tar_archive_name"]\n"
	cd $product_install_dir
	fn_stoponerror $? $LINENO
	
	ls "$product_release_install_dir"
	fn_stoponerror $? $LINENO	
	
	ls "$product_release_name"
	fn_stoponerror $? $LINENO
	
	tar -czf "$dir0/$product_tar_archive_name" "$product_release_name"
	fn_stoponerror $? $LINENO
	
	ls "$dir0/$product_tar_archive_name"
	fn_stoponerror $? $LINENO
	
else
	printf "\n\nUnknown action: ["$action"] (arguments: ["$1"], ["$2"] ).\n\n"
	fn_print_usage
fi



printf "\n"$LINENO": End Of File\n"
