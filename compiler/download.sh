#!/bin/bash
set -ex

# Create directory for source files
mkdir -p "$TARGET_COMPILE/source"
cd "$TARGET_COMPILE/source"

## gcc
if [ ! -f gcc-$PKG_GCC.tar.gz ]; then
  wget "https://ftp.gnu.org/gnu/gcc/gcc-${PKG_GCC}/gcc-${PKG_GCC}.tar.gz"
  tar -xzf gcc-${PKG_GCC}.tar.gz
fi
# gdb
if [[ -z "$TRAVIS" && ! -f gdb-$PKG_GDB.tar.gz ]]; then
  wget "https://ftp.gnu.org/gnu/gdb/gdb-${PKG_GDB}.tar.gz"
  tar -xzf gdb-${PKG_GDB}.tar.gz
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
