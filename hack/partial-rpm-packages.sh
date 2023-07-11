#!/bin/bash

sudo dnf -y install \
  bzip2-devel \
  libffi-devel \
  openssl-devel \
  make \
  zlib-devel \
  perl \
  ncurses-devel \
  sqlite \
  sqlite-devel \
  git \
  wget \
  curl \
  nano \
  vim \
  unzip \
  bind-utils \
  tar \
  util-linux-user \
  gcc \
  podman

sudo dnf -y groupinstall "Development Tools"