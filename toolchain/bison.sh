#!/usr/bin/env bash

tar -xf $LFS/sources/bison-3.0.4.tar.xz -C $LFS/sources

cd $LFS/sources/bison-3.0.4

./configure --prefix=/tools

make

make install

cd $LFS/sources

rm -Rf bison-3.0.4

cd $MRX