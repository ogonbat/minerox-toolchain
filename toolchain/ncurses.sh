#!/usr/bin/env bash

tar -xf $LFS/sources/ncurses-6.0.tar.gz -C $LFS/sources

cd $LFS/sources/ncurses-6.0

sed -i s/mawk// configure

./configure --prefix=/tools \
            --with-shared   \
            --without-debug \
            --without-ada   \
            --enable-widec  \
            --enable-overwrite

make

make install

cd $LFS/sources

rm -Rf ncurses-6.0

cd $MRX