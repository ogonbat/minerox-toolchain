#!/usr/bin/env bash

tar -xf $LFS/sources/texinfo-6.4.tar.xz -C $LFS/sources

cd $LFS/sources/texinfo-6.4

./configure --prefix=/tools

make

make install

cd $LFS/sources

rm -Rf texinfo-6.4

cd $MRX