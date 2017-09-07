#!/usr/bin/env bash

tar -xf $LFS/sources/linux-4.12.7.tar.xz -C $LFS/sources

cd $LFS/sources/linux-4.12.7

make mrproper

make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* /tools/include

cd $LFS/sources

rm -Rf linux-4.12.7

cd $MRX