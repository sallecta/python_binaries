# python_binaries

Python binaries for Linux Mint.
https://github.com/sallecta/python_binaries


## Building Python binaries

Check target Python version in settings.sh 

```
./build.sh make 64
./build.sh deploy 64
./build.sh clean
```


## Installation

Binaries located at Binaries folder, build results located 
in ignore/install directory.

Unpack selected binaries archive, or copy directory that contains 
build results 
to desired location and enter terminal there.
```
./fix_portable_path.sh 

```
To make binaries accessible from any location run symlinks script.

```
./symlinks_in_local_bin.sh link

```


## Uninstall

If symlinks created, open terminal where Python binaries located 
and execute following.

```
./symlinks_in_local_bin.sh unlink

```
Delete Python binaries directory.


## Usage

Python launchers named as "sallectapip[PythonVersion]" or
"sallectapython[PythonVersion]" 
where [PythonVersion] is major + '.' and minor versions of Python release. 

For example, here is Python launchers for version 3.9.16:
- sallectapip3.9
- sallectapython3.9 
