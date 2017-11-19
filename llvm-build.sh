#!/bin/sh
set -e

mkdir -p $HOME/src
LLVM_ROOT=$HOME/src/llvm
INSTALL_DIR=/opt
RELEASE=release_40

function enlist() {
	if [ ! -d $2 ]; then
		git clone git@github.com:llvm-mirror/$1 $2
	else
		echo $2 already exists, skipping cloning $1 into it...
	fi

	cd $2
	git checkout $RELEASE
}

# Get the sources
enlist llvm $LLVM_ROOT
enlist clang $LLVM_ROOT/tools/clang
enlist libcxx $LLVM_ROOT/projects/libcxx
enlist libcxxabi $LLVM_ROOT/projects/libcxxabi

# Set up the installation dir
sudo chown -R `whoami` $INSTALL_DIR
sudo chgrp -R staff $INSTALL_DIR
mkdir -p $INSTALL_DIR/debug
mkdir -p $INSTALL_DIR/release

# Run the Debug build
function build() {
	mkdir -p /var/tmp/llvm/$1
	cd /var/tmp/llvm/$1

	time cmake \
		-DCMAKE_INSTALL_PREFIX=$INSTALL_DIR/$1 \
		-DLLVM_ENABLE_RTTI=On \
		-DCMAKE_BUILD_TYPE=$1 \
		-DLLVM_ENABLE_ASSERTIONS=$(if [ $1 = Debug ]; then echo On; else echo Off; fi) \
		$LLVM_ROOT

	time make -j8
	time make install
}

build Debug
build MinSizeRel

