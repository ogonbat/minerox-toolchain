#!/usr/bin/env bash

tar -xf $LFS/sources/patch-2.7.5.tar.xz -C $LFS/sources

cd $LFS/sources/patch-2.7.5

./configure --prefix=/tools

make

make install

cd $LFS/sources

rm -Rf patch-2.7.5

cd $MRX