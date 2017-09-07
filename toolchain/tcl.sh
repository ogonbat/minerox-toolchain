#!/usr/bin/env bash

tar -xf $LFS/sources/tcl-core8.6.7-src.tar.gz -C $LFS/sources

cd $LFS/sources/tcl8.6.7

cd unix
./configure --prefix=/tools

make

make install

chmod -v u+w /tools/lib/libtcl8.6.so

make install-private-headers

ln -sv tclsh8.6 /tools/bin/tclsh

cd $LFS/sources

rm -Rf tcl8.6.7

cd $MRX