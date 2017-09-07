#!/usr/bin/env bash

tar -xf $LFS/sources/gawk-4.1.4.tar.xz -C $LFS/sources

cd $LFS/sources/gawk-4.1.4

./configure --prefix=/tools

make

make install

cd $LFS/sources

rm -Rf gawk-4.1.4

cd $MRX