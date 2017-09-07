#!/usr/bin/env bash

tar -xf $LFS/sources/bzip2-1.0.6.tar.gz -C $LFS/sources

cd $LFS/sources/bzip2-1.0.6

make PREFIX=/tools install

cd $LFS/sources

rm -Rf bzip2-1.0.6

cd $MRX