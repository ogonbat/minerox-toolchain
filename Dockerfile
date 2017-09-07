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
RUN apt-get install -y apt-utils
RUN apt-get install -y wget build-essential bison gawk m4 texinfo file
RUN apt-get -y autoremove
RUN rm -Rf /var/cache/apt
RUN ln -fsv /bin/bash /bin/sh

RUN mkdir -p $LFS $LFS/tools $LFS/sources
RUN chmod -v a+wt $LFS/sources
RUN ln -sv $LFS/tools /

WORKDIR $LFS/sources

RUN wget http://www.linuxfromscratch.org/lfs/view/${LFS_VERSION}/wget-list
RUN wget http://www.linuxfromscratch.org/lfs/view/${LFS_VERSION}/md5sums
RUN wget --input-file=wget-list --continue --directory-prefix=$LFS/sources
RUN pushd $LFS/sources && \
    md5sum -c md5sums && \
    popd

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools/bin

#install binutils
RUN tar -xf binutils-2.29.tar.bz2
RUN cd binutils-2.29

RUN mkdir -v build
RUN cd       build
RUN ../configure --prefix=/tools --with-sysroot=$LFS --with-lib-path=/tools/lib --target=$LFS_TGT --disable-nls --disable-werror
RUN make
RUN case $(uname -m) in \
  x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;; \
esac
RUN make install
RUN cd $LFS/sources
RUN rm -Rf binutils-2.29