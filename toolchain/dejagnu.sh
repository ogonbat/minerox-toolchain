#!/usr/bin/env bash

tar -xf $LFS/sources/dejagnu-1.6.tar.gz -C $LFS/sources

cd $LFS/sources/dejagnu-1.6

./configure --prefix=/tools

make

make install

cd $LFS/sources

rm -Rf dejagnu-1.6

cd $MRX