#!/usr/bin/env bash

tar -xf $LFS/sources/m4-1.4.18.tar.xz -C $LFS/sources

cd $LFS/sources/m4-1.4.18

./configure --prefix=/tools

make

make install

cd $LFS/sources

rm -Rf m4-1.4.18

cd $MRX