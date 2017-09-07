#!/usr/bin/env bash

tar -xf $LFS/sources/expect5.45.tar.gz -C $LFS/sources

cd $LFS/sources/expect5.45

cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure

./configure --prefix=/tools       \
            --with-tcl=/tools/lib \
            --with-tclinclude=/tools/include

make

make SCRIPTS="" install

cd $LFS/sources

rm -Rf expect5.45

cd $MRX