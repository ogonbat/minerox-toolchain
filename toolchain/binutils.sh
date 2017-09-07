#!/usr/bin/env bash

tar -xf $LFS/sources/binutils-2.29.tar.bz2 -C $LFS/sources

cd $LFS/sources/binutils-2.29

mkdir -v build
cd       build


../configure --prefix=/tools            \
             --with-sysroot=$LFS        \
             --with-lib-path=/tools/lib \
             --target=$LFS_TGT          \
             --disable-nls              \
             --disable-werror

make

case $(uname -m) in
  x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
esac

make install

cd $LFS/sources

rm -Rf binutils-2.29

cd $MRX