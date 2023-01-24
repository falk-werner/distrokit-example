ARG REGISTRY_PREFIX=''
ARG CODENAME=focal

FROM ${REGISTRY_PREFIX}ubuntu:${CODENAME} as builder
RUN apt update \
    && DEBIAN_FRONTEND=noninteractive \
    apt install -yq --no-install-recommends \
        xz-utils \
        build-essential \
        autoconf \
        libtool \
        automake \
        libncurses5-dev \
        gawk \
        flex \
        bison \
        texinfo \
        pkg-config \
        wget \
        ca-certificates \
        python3 \
        python3-setuptools \
        libxml-parser-perl \
        bc

ARG TOOLCHAIN=oselas.toolchain-2020.08.0-arm-v7a-linux-gnueabihf-gcc-10.2.1-clang-10.0.1-glibc-2.32-binutils-2.35-kernel-5.8-sanitized_2020.08.0-1-ubuntu20.04+1_amd64.deb
COPY ${TOOLCHAIN} ${TOOLCHAIN}
RUN DEBIAN_FRONTEND=noninteractive \
    apt install -yq ./${TOOLCHAIN} \
    && rm ${TOOLCHAIN}

ARG USERID=1000
RUN useradd -u "$USERID" -ms /bin/bash user

ARG PTXDIST_VERSION=2021.02.0
COPY ptxdist-${PTXDIST_VERSION}.tar.bz2 /tmp/ptxdist.tar.bz2
RUN tar -xf /tmp/ptxdist.tar.bz2 \
    && cd ptxdist-${PTXDIST_VERSION} \
    && ./configure \
    && make \
    && make install \
    && cd - \
    && rm -rf ptxdist-${PTXDIST_VERSION}

WORKDIR "/home/user/ptxproj"
