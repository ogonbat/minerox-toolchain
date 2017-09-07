#!/usr/bin/env bash

tar -xf $LFS/sources/gzip-1.8.tar.xz -C $LFS/sources

cd $LFS/sources/gzip-1.8

./configure --prefix=/tools

make

make install

cd $LFS/sources

rm -Rf gzip-1.8

cd $MRX