#!/usr/bin/env bash

tar -xf $LFS/sources/sed-4.4.tar.xz -C $LFS/sources

cd $LFS/sources/sed-4.4

./configure --prefix=/tools

make

make install

cd $LFS/sources

rm -Rf sed-4.4

cd $MRX