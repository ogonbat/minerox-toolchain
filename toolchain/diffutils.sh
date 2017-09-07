#!/usr/bin/env bash

tar -xf $LFS/sources/diffutils-3.6.tar.xz -C $LFS/sources

cd $LFS/sources/diffutils-3.6

./configure --prefix=/tools

make

make install

cd $LFS/sources

rm -Rf diffutils-3.6

cd $MRX