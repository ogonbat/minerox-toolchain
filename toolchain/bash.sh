#!/usr/bin/env bash

tar -xf $LFS/sources/bash-4.4.tar.gz -C $LFS/sources

cd $LFS/sources/bash-4.4

./configure --prefix=/tools --without-bash-malloc

make

make install

ln -sv bash /tools/bin/sh

cd $LFS/sources

rm -Rf bash-4.4

cd $MRX