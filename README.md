# Lotus Compiler

## Prerequisites Development packages for Ubuntu Linux Ubuntu 16.04 LTS:

```sh
sudo apt update
sudo apt build-essential
sudo apt install flex bison
```

## HOW TO BUILD

On FreeBSD, please use "gmake" command to build the makefile.
```sh    
gmake 
```
On Linux, please use "make" command to build the makefile.
```sh
make
```

## HOW TO TESTS

On FreeBSD, use this makefile target to test file.
```sh
gmake test
```
On Linux,  use this makefile target to test file.
```sh    
make test
```

If you want to test other testing file, you can put your testing file into 
test(directory) and run target in the makefile.

