#!/usr/bin/env bash

tar -xf $LFS/sources/util-linux-2.30.1.tar.xz -C $LFS/sources

cd $LFS/sources/util-linux-2.30.1

./configure --prefix=/tools                \
            --without-python               \
            --disable-makeinstall-chown    \
            --without-systemdsystemunitdir \
            --without-ncurses              \
            PKG_CONFIG=""

make

make install

cd $LFS/sources

rm -Rf util-linux-2.30.1

cd $MRX