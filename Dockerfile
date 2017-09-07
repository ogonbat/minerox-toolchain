FROM debian:stretch

MAINTAINER cingusoft@gmail.com

USER root
ENV	MRX_VERSION=0.0.1
ENV LFS_VERSION=8.1
ENV LFS=/mnt/lfs
ENV LC_ALL=POSIX
ENV MAKEFLAGS='-j 4'
ENV LFS_TGT=x86_64-lfs-linux-gnu


RUN apt-get update
RUN apt-get install -y wget build-essential bison gawk m4 texinfo file
RUN apt-get -y autoremove
RUN rm -Rf /var/cache/apt
RUN ln -fsv /bin/bash /bin/sh

RUN mkdir -p $LFS $LFS/tools $LFS/sources
RUN chmod -v a+wt $LFS/sources
RUN ln -sv $LFS/tools /

WORKDIR $LFS/sources

RUN wget --progress=dot http://www.linuxfromscratch.org/lfs/view/${LFS_VERSION}/wget-list
RUN wget --progress=dot http://www.linuxfromscratch.org/lfs/view/${LFS_VERSION}/md5sums
RUN wget --input-file=wget-list --continue --progress=dot --directory-prefix=$LFS/sources
RUN pushd $LFS/sources && \
    md5sum -c md5sums && \
    popd

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools/bin

#install binutils
RUN tar -xf binutils-2.29.tar.bz2 && \
    cd binutils-2.29 && \
    mkdir -v build && \
    cd       build && \
    ../configure --prefix=/tools --with-sysroot=$LFS --with-lib-path=/tools/lib --target=$LFS_TGT --disable-nls --disable-werror && \
    make && \
    case $(uname -m) in \
        x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;; \
    esac && \
    make install && \
    cd $LFS/sources && \
    rm -Rf binutils-2.29

RUN tar -xf gcc-7.2.0.tar.xz &&\
    cd gcc-7.2.0 &&\
    tar -xf ../mpfr-3.1.5.tar.xz &&\
    mv -v mpfr-3.1.5 mpfr &&\
    tar -xf ../gmp-6.1.2.tar.xz &&\
    mv -v gmp-6.1.2 gmp &&\
    tar -xf ../mpc-1.0.3.tar.gz &&\
    mv -v mpc-1.0.3 mpc &&\
    for file in gcc/config/{linux,i386/linux{,64}}.h \
    do \
        cp -uv $file{,.orig} \
        sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
            -e 's@/usr@/tools@g' $file.orig > $file \
        echo ' \
    #undef STANDARD_STARTFILE_PREFIX_1 \
    #undef STANDARD_STARTFILE_PREFIX_2 \
    #define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/" \
    #define STANDARD_STARTFILE_PREFIX_2 ""' >> $file \
        touch $file.orig \
    done &&\
    case $(uname -m) in \
    x86_64)
        sed -e '/m64=/s/lib64/lib/' \
            -i.orig gcc/config/i386/t-linux64 \
        ;; \
    esac &&\
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
        cd $LFS/sources &&\
        rm -Rf gcc-7.2.0 &&\
        rm -Rf mpfr &&\
        rm -Rf gmp &&\
        rm -Rf mpc &&\
