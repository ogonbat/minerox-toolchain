#!/usr/bin/env bash

tar -xf $LFS/sources/xz-5.2.3.tar.xz -C $LFS/sources

cd $LFS/sources/xz-5.2.3

./configure --prefix=/tools

make

make install

cd $LFS/sources

rm -Rf xz-5.2.3

cd $MRX