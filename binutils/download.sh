#!/bin/bash
set -ex

# Create directory for source files
mkdir -p "$TARGET_COMPILE/source"
cd "$TARGET_COMPILE/source"

# binutils
if [ ! -f binutils-$PKG_BINUTILS.tar.gz ]; then
  wget "https://ftp.gnu.org/gnu/binutils/binutils-${PKG_BINUTILS}.tar.gz"
  tar -xzf binutils-${PKG_BINUTILS}.tar.gz
fi
# automake
if [ ! -f automake-${PKG_AUTOMAKE}.tar.gz ]; then
  wget "https://ftp.gnu.org/gnu/automake/automake-${PKG_AUTOMAKE}.tar.gz"
  tar -xzf automake-${PKG_AUTOMAKE}.tar.gz
fi
# autoconf
if [ ! -f autoconf-${PKG_AUTOCONF}.tar.gz ]; then
  wget "https://ftp.gnu.org/gnu/autoconf/autoconf-${PKG_AUTOCONF}.tar.gz"
  tar -xzf autoconf-${PKG_AUTOCONF}.tar.gz
fi