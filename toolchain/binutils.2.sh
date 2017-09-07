#!/usr/bin/env bash

tar -xf $LFS/sources/binutils-2.29.tar.bz2 -C $LFS/sources

cd $LFS/sources/binutils-2.29

mkdir -v build
cd       build


CC=$LFS_TGT-gcc                \
AR=$LFS_TGT-ar                 \
RANLIB=$LFS_TGT-ranlib         \
../configure                   \
    --prefix=/tools            \
    --disable-nls              \
    --disable-werror           \
    --with-lib-path=/tools/lib \
    --with-sysroot

make

make install

make -C ld clean
make -C ld LIB_PATH=/usr/lib:/lib
cp -v ld/ld-new /tools/bin

cd $LFS/sources

rm -Rf binutils-2.29

cd $MRX