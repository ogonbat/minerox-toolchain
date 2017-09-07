#!/usr/bin/env bash

tar -xf $LFS/sources/perl-5.26.0.tar.xz -C $LFS/sources

cd $LFS/sources/perl-5.26.0

sed -e '9751 a#ifndef PERL_IN_XSUB_RE' \
    -e '9808 a#endif'                  \
    -i regexec.c

sh Configure -des -Dprefix=/tools -Dlibs=-lm

make

cp -v perl cpan/podlators/scripts/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.26.0
cp -Rv lib/* /tools/lib/perl5/5.26.0

cd $LFS/sources

rm -Rf perl-5.26.0

cd $MRX