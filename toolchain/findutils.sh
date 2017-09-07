#!/usr/bin/env bash

tar -xf $LFS/sources/findutils-4.6.0.tar.gz -C $LFS/sources

cd $LFS/sources/findutils-4.6.0

./configure --prefix=/tools

make

make install

cd $LFS/sources

rm -Rf findutils-4.6.0

cd $MRX