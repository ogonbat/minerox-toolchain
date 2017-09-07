#!/usr/bin/env bash

tar -xf $LFS/sources/glibc-2.26.tar.xz -C $LFS/sources

cd $LFS/sources/glibc-2.26


mkdir -v build
cd       build


../configure                             \
      --prefix=/tools                    \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2             \
      --with-headers=/tools/include      \
      libc_cv_forced_unwind=yes          \
      libc_cv_c_cleanup=yes

make

make install

echo "Do a Test"
echo 'int main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep ': /tools'

rm -v dummy.c a.out


cd $LFS/sources

rm -Rf glibc-2.26

cd $MRX