#!/usr/bin/env bash

tar -xf $LFS/sources/coreutils-8.27.tar.xz -C $LFS/sources

cd $LFS/sources/coreutils-8.27

FORCE_UNSAFE_CONFIGURE=1  ./configure --prefix=/tools --enable-install-program=hostname

FORCE_UNSAFE_CONFIGURE=1 make

make install

cd $LFS/sources

rm -Rf coreutils-8.27

cd $MRX