FROM debian:stretch

MAINTAINER cingusoft@gmail.com

USER root
ENV	MRX_VERSION=0.0.1
ENV LFS_VERSION=8.1
ENV LFS=/mnt/lfs
ENV LC_ALL=POSIX
ENV MAKEFLAGS='-j 4'
ENV LFS_TGT=x86_64-lfs-linux-gnu


RUN apt-get update &&\
    apt-get install -q -y wget build-essential bison gawk m4 texinfo file &&\
    apt-get -q -y autoremove &&\
    rm -Rf /var/cache/apt &&\
    ln -fsv /bin/bash /bin/sh

RUN mkdir -p $LFS $LFS/tools $LFS/sources &&\
    chmod -v a+wt $LFS/sources &&\
    ln -sv $LFS/tools /

WORKDIR $LFS/sources
COPY [ "scripts/check_version.sh", "$LFS/sources/" ]
RUN chmod -R 755 check_version.sh
RUN ./check_version.sh

RUN wget --progress=dot http://www.linuxfromscratch.org/lfs/view/${LFS_VERSION}/wget-list &&\
    wget --progress=dot http://www.linuxfromscratch.org/lfs/view/${LFS_VERSION}/md5sums &&\
    wget --input-file=wget-list --continue --progress=dot --directory-prefix=$LFS/sources &&\
    pushd $LFS/sources && \
    md5sum -c md5sums && \
    popd

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools/bin

#install binutils
RUN tar -xf binutils-2.29.tar.bz2 && \
    pushd $LFS/sources/binutils-2.29 && \
    mkdir -v build && \
    cd       build && \
    ../configure --prefix=/tools --with-sysroot=$LFS --with-lib-path=/tools/lib --target=$LFS_TGT --disable-nls --disable-werror && \
    make && \
    case $(uname -m) in \
        x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;; \
    esac && \
    make install && \
    popd && \
    rm -Rf binutils-2.29

#install gcc
COPY [ "scripts/toolchain/gcc.sh", "$LFS/sources/" ]
RUN chmod -R 755 gcc.sh
RUN tar -xf gcc-7.2.0.tar.xz &&\
    pushd $LFS/sources/gcc-7.2.0 &&\
    mv -v ../gcc.sh . &&\
    tar -xf ../mpfr-3.1.5.tar.xz &&\
    mv -v mpfr-3.1.5 mpfr &&\
    tar -xf ../gmp-6.1.2.tar.xz &&\
    mv -v gmp-6.1.2 gmp &&\
    tar -xf ../mpc-1.0.3.tar.gz &&\
    mv -v mpc-1.0.3 mpc &&\
    ./gcc.sh &&\
    mkdir -v build &&\
    cd       build &&\
    ../configure                                       \
        --target=$LFS_TGT                              \
        --prefix=/tools                                \
        --with-glibc-version=2.11                      \
        --with-sysroot=$LFS                            \
        --with-newlib                                  \
        --without-headers                              \
        --with-local-prefix=/tools                     \
        --with-native-system-header-dir=/tools/include \
        --disable-nls                                  \
        --disable-shared                               \
        --disable-multilib                             \
        --disable-decimal-float                        \
        --disable-threads                              \
        --disable-libatomic                            \
        --disable-libgomp                              \
        --disable-libmpx                               \
        --disable-libquadmath                          \
        --disable-libssp                               \
        --disable-libvtv                               \
        --disable-libstdcxx                            \
        --enable-languages=c,c++ &&\
        make &&\
        make install &&\
        popd &&\
        rm -Rf gcc-7.2.0 &&\
        rm -Rf mpfr &&\
        rm -Rf gmp &&\
        rm -Rf mpc

#install linux
RUN tar -xf linux-4.12.7.tar.xz &&\
    pushd $LFS/sources/linux-4.12.7 &&\
    make mrproper &&\
    make INSTALL_HDR_PATH=dest headers_install &&\
    cp -rv dest/include/* /tools/include &&\
    popd &&\
    rm -Rf linux-4.12.7

#install glibc
RUN tar -xf glibc-2.26.tar.xz &&\
    pushd $LFS/sources/glibc-2.26 &&\
    mkdir -v build &&\
    cd       build &&\
    ../configure                             \
        --prefix=/tools                    \
        --host=$LFS_TGT                    \
        --build=$(../scripts/config.guess) \
        --enable-kernel=3.2             \
        --with-headers=/tools/include      \
        libc_cv_forced_unwind=yes          \
        libc_cv_c_cleanup=yes &&\
        make &&\
        make install &&\
        popd &&\
        rm -Rf glibc-2.26

#install libstdc
RUN tar -xf gcc-7.2.0.tar.xz &&\
    pushd $LFS/sources/gcc-7.2.0 &&\
    mkdir -v build &&\
    cd       build &&\
    ../libstdc++-v3/configure           \
        --host=$LFS_TGT                 \
        --prefix=/tools                 \
        --disable-multilib              \
        --disable-nls                   \
        --disable-libstdcxx-threads     \
        --disable-libstdcxx-pch         \
        --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/7.2.0 &&\
        make &&\
        make install &&\
        popd &&\
        rm -Rf gcc-7.2.0

#install binutils second step
RUN tar -xf binutils-2.29.tar.bz2 &&\
    pushd $LFS/sources/binutils-2.29 &&\
    mkdir -v build &&\
    cd       build &&\
    CC=$LFS_TGT-gcc                \
    AR=$LFS_TGT-ar                 \
    RANLIB=$LFS_TGT-ranlib         \
    ../configure                   \
        --prefix=/tools            \
        --disable-nls              \
        --disable-werror           \
        --with-lib-path=/tools/lib \
        --with-sysroot &&\
        make &&\
        make install &&\
        make -C ld clean &&\
        make -C ld LIB_PATH=/usr/lib:/lib &&\
        cp -v ld/ld-new /tools/bin &&\
        popd &&\
        rm -Rf binutils-2.29

#install gcc second step
COPY [ "scripts/toolchain/gcc_2.sh", "$LFS/sources/" ]
RUN chmod -R 755 gcc_2.sh
RUN tar -xf gcc-7.2.0.tar.xz &&\
    pushd $LFS/sources/gcc-7.2.0 &&\
    mv ../gcc_2.sh . &&\
    ./gcc_2.sh &&\
    tar -xf ../mpfr-3.1.5.tar.xz &&\
    mv -v mpfr-3.1.5 mpfr &&\
    tar -xf ../gmp-6.1.2.tar.xz &&\
    mv -v gmp-6.1.2 gmp &&\
    tar -xf ../mpc-1.0.3.tar.gz &&\
    mv -v mpc-1.0.3 mpc &&\
    mkdir -v build &&\
    cd       build &&\
    CC=$LFS_TGT-gcc                                    \
    CXX=$LFS_TGT-g++                                   \
    AR=$LFS_TGT-ar                                     \
    RANLIB=$LFS_TGT-ranlib                             \
    ../configure                                       \
        --prefix=/tools                                \
        --with-local-prefix=/tools                     \
        --with-native-system-header-dir=/tools/include \
        --enable-languages=c,c++                       \
        --disable-libstdcxx-pch                        \
        --disable-multilib                             \
        --disable-bootstrap                            \
        --disable-libgomp &&\
        make &&\
        make install &&\
        ln -sv gcc /tools/bin/cc &&\
        popd &&\
        rm -Rf gcc-7.2.0 &&\
        rm -Rf mpfr &&\
        rm -Rf gmp &&\
        rm -Rf mpc

RUN tar -xf tcl-core8.6.7-src.tar.gz &&\
    pushd $LFS/sources/tcl8.6.7 &&\
    cd unix &&\
    ./configure --prefix=/tools &&\
    make &&\
    make install &&\
    chmod -v u+w /tools/lib/libtcl8.6.so &&\
    make install-private-headers &&\
    ln -sv tclsh8.6 /tools/bin/tclsh &&\
    popd &&\
    rm -Rf tcl8.6.7

RUN tar -xf expect5.45.tar.gz &&\
    pushd $LFS/sources/expect5.45 &&\
    cp -v configure{,.orig} &&\
    sed 's:/usr/local/bin:/bin:' configure.orig > configure &&\
    ./configure --prefix=/tools   \
            --with-tcl=/tools/lib \
            --with-tclinclude=/tools/include &&\
    make &&\
    make SCRIPTS="" install &&\
    popd &&\
    rm -Rf expect5.45

RUN tar -xf dejagnu-1.6.tar.gz &&\
    pushd $LFS/sources/dejagnu-1.6 &&\
    ./configure --prefix=/tools &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf dejagnu-1.6

RUN tar -xf check-0.11.0.tar.gz &&\
    pushd $LFS/sources/check-0.11.0 &&\
    PKG_CONFIG= ./configure --prefix=/tools &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf check-0.11.0

RUN tar -xf ncurses-6.0.tar.gz &&\
    pushd $LFS/sources/ncurses-6.0 &&\
    sed -i s/mawk// configure &&\
    ./configure --prefix=/tools \
            --with-shared   \
            --without-debug \
            --without-ada   \
            --enable-widec  \
            --enable-overwrite &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf ncurses-6.0

RUN tar -xf bash-4.4.tar.gz &&\
    pushd $LFS/sources/bash-4.4 &&\
    ./configure --prefix=/tools --without-bash-malloc &&\
    make &&\
    make install &&\
    ln -sv bash /tools/bin/sh &&\
    popd &&\
    rm -Rf bash-4.4

RUN tar -xf bison-3.0.4.tar.xz &&\
    pushd $LFS/sources/bison-3.0.4 &&\
    ./configure --prefix=/tools &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf bison-3.0.4

RUN tar -xf bzip2-1.0.6.tar.gz &&\
    pushd $LFS/sources/bzip2-1.0.6 &&\
    make PREFIX=/tools install &&\
    popd &&\
    rm -Rf bzip2-1.0.6

RUN tar -xf coreutils-8.27.tar.xz &&\
    pushd $LFS/sources/coreutils-8.27 &&\
    FORCE_UNSAFE_CONFIGURE=1  ./configure --prefix=/tools --enable-install-program=hostname &&\
    FORCE_UNSAFE_CONFIGURE=1 make &&\
    make install &&\
    popd &&\
    rm -Rf coreutils-8.27

RUN tar -xf diffutils-3.6.tar.xz &&\
    pushd $LFS/sources/diffutils-3.6 &&\
    ./configure --prefix=/tools &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf diffutils-3.6

RUN tar -xf file-5.31.tar.gz &&\
    pushd $LFS/sources/file-5.31 &&\
    ./configure --prefix=/tools &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf file-5.31

RUN tar -xf findutils-4.6.0.tar.gz &&\
    pushd $LFS/sources/findutils-4.6.0 &&\
    ./configure --prefix=/tools &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf findutils-4.6.0

RUN tar -xf gawk-4.1.4.tar.xz &&\
    pushd $LFS/sources/gawk-4.1.4 &&\
    ./configure --prefix=/tools &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf gawk-4.1.4

RUN tar -xf gettext-0.19.8.1.tar.xz &&\
    pushd $LFS/sources/gettext-0.19.8.1 &&\
    cd gettext-tools &&\
    EMACS="no" ./configure --prefix=/tools --disable-shared &&\
    make -C gnulib-lib &&\
    make -C intl pluralx.c &&\
    make -C src msgfmt &&\
    make -C src msgmerge &&\
    make -C src xgettext &&\
    cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin &&\
    popd &&\
    rm -Rf gettext-0.19.8.1

RUN tar -xf grep-3.1.tar.xz &&\
    pushd $LFS/sources/grep-3.1 &&\
    ./configure --prefix=/tools &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf grep-3.1

RUN tar -xf gzip-1.8.tar.xz &&\
    pushd $LFS/sources/gzip-1.8 &&\
    ./configure --prefix=/tools &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf gzip-1.8

RUN tar -xf m4-1.4.18.tar.xz &&\
    pushd $LFS/sources/m4-1.4.18 &&\
    ./configure --prefix=/tools &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf m4-1.4.18

RUN tar -xf make-4.2.1.tar.bz2 &&\
    pushd $LFS/sources/make-4.2.1 &&\
    ./configure --prefix=/tools --without-guile &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf make-4.2.1

RUN tar -xf patch-2.7.5.tar.xz &&\
    pushd $LFS/sources/patch-2.7.5 &&\
    ./configure --prefix=/tools &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf patch-2.7.5

RUN tar -xf perl-5.26.0.tar.xz &&\
    pushd $LFS/sources/perl-5.26.0 &&\
    sed -e '9751 a#ifndef PERL_IN_XSUB_RE' \
        -e '9808 a#endif'                  \
        -i regexec.c &&\
    sh Configure -des -Dprefix=/tools -Dlibs=-lm &&\
    make &&\
    cp -v perl cpan/podlators/scripts/pod2man /tools/bin &&\
    mkdir -pv /tools/lib/perl5/5.26.0 &&\
    cp -Rv lib/* /tools/lib/perl5/5.26.0 &&\
    popd &&\
    rm -Rf perl-5.26.0

RUN tar -xf sed-4.4.tar.xz &&\
    pushd $LFS/sources/sed-4.4 &&\
    ./configure --prefix=/tools &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf sed-4.4

RUN tar -xf tar-1.29.tar.xz &&\
    pushd $LFS/sources/tar-1.29 &&\
    FORCE_UNSAFE_CONFIGURE=1 ./configure --prefix=/tools &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf tar-1.29

RUN tar -xf texinfo-6.4.tar.xz &&\
    pushd $LFS/sources/texinfo-6.4 &&\
    ./configure --prefix=/tools &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf texinfo-6.4

RUN tar -xf util-linux-2.30.1.tar.xz &&\
    pushd $LFS/sources/util-linux-2.30.1 &&\
    ./configure --prefix=/tools                \
                --without-python               \
                --disable-makeinstall-chown    \
                --without-systemdsystemunitdir \
                --without-ncurses              \
                PKG_CONFIG="" &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf util-linux-2.30.1

RUN tar -xf xz-5.2.3.tar.xz &&\
    pushd $LFS/sources/xz-5.2.3 &&\
    ./configure --prefix=/tools &&\
    make &&\
    make install &&\
    popd &&\
    rm -Rf xz-5.2.3

RUN strip --strip-debug /tools/lib/* &&\
    /usr/bin/strip --strip-unneeded /tools/{,s}bin/* &&\
    rm -rf /tools/{,share}/{info,man,doc} &&\
    rm /tools &&\
    mv /mnt/lfs/tools /tools &&\
    mv /mnt/lfs/sources /sources &&\
    rm -rf /mnt/lfs &&\
    rm -rf /bin /boot /etc /home /lib /lib64 /media /mnt /opt /root /sbin /srv /tmp /usr /var || //tools/bin/true &&\
    /tools/bin/mkdir -pv /bin /root && \
	/tools/bin/ln -sv /tools/bin/bash /bin && \
	/tools/bin/ln -sv bash /bin/sh

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools/bin:/tools/sbin
CMD ["/bin/sh"]
