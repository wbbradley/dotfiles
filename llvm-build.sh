#!/bin/sh
set -ex

LLVM_ROOT=$HOME/src/llvm-test
INSTALL_DIR=/opt
RELEASE=release_40

function enlist() {
	git clone git@github.com:llvm-mirror/$1 $2
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

# Run the actual build
mkdir -p /var/tmp/llvm/build
cd /var/tmp/llvm/build

time cmake \
	-DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
	-DLLVM_ENABLE_RTTI=On \
	-DCMAKE_BUILD_TYPE=Debug \
	-DLLVM_ENABLE_ASSERTIONS=On
	$LLVM_ROOT

time make -j8
time make install
