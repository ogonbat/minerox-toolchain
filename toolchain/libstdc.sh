#!/usr/bin/env bash

tar -xf $LFS/sources/gcc-7.2.0.tar.xz -C $LFS/sources

cd $LFS/sources/gcc-7.2.0


mkdir -v build
cd       build


../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --prefix=/tools                 \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-threads     \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/7.2.0

make

make install

cd $LFS/sources

rm -Rf gcc-7.2.0

cd $MRX
