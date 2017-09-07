FROM debian:stretch

MAINTAINER cingusoft@gmail.com

USER root
ENV	MRX_VERSION=0.0.1
ENV LFS_VERSION=8.1
ENV LFS=/mnt/lfs
ENV LC_ALL=POSIX
ENV MAKEFLAGS='-j 4'
ENV LFS_TGT=x86_64-lfs-linux-gnu

RUN echo $PATH
RUN apt-get update
RUN apt-get install --no-install-recommends -y -q wget build-essential bison gawk m4 texinfo aria2 file
RUN apt-get -q -y autoremove
RUN rm -Rf /var/cache/apt
RUN ln -fsv /bin/bash /bin/sh

RUN mkdir -p ${LFS} ${LFS}/tools ${LFS}/sources
RUN chmod -v a+wt ${LFS}/sources

RUN ln -sv ${LFS}/tools /
RUN cd ${LFS}/sources
RUN wget http://www.linuxfromscratch.org/lfs/view/${LFS_VERSION}/wget-list
RUN wget http://www.linuxfromscratch.org/lfs/view/${LFS_VERSION}/md5sums
RUN aria2c -i ${LFS}/sources/wget-list -d ${LFS}/sources --check-certificate=false
RUN md5sum -c md5sums


ENV PATH=/tools/bin:/bin:/usr/bin