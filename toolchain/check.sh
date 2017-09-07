#!/usr/bin/env bash

tar -xf $LFS/sources/check-0.11.0.tar.gz -C $LFS/sources

cd $LFS/sources/check-0.11.0

PKG_CONFIG= ./configure --prefix=/tools

make

make install

cd $LFS/sources

rm -Rf check-0.11.0

cd $MRX