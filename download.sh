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
## gcc
if [ ! -f gcc-$PKG_GCC.tar.gz ]; then
  wget "https://ftp.gnu.org/gnu/gcc/gcc-${PKG_GCC}/gcc-${PKG_GCC}.tar.gz"
  tar -xzf gcc-${PKG_GCC}.tar.gz
fi
# gdb
if [ ! -f gdb-$PKG_GDB.tar.gz ]; then
  wget "https://ftp.gnu.org/gnu/gdb/gdb-${PKG_GDB}.tar.gz"
  tar -xzf gdb-${PKG_GDB}.tar.gz
fi
# glibc
if [ ! -f glibc-$PKG_GLIBC.tar.gz ]; then
  wget "https://ftp.gnu.org/gnu/libc/glibc-${PKG_GLIBC}.tar.gz"
  tar -xzf glibc-${PKG_GLIBC}.tar.gz
fi
# newlib
if [ ! -f newlib-${PKG_NEWLIB}.tar.gz ]; then
  wget "https://www.sourceware.org/pub/newlib/newlib-${PKG_NEWLIB}.tar.gz"
  tar -xzf newlib-${PKG_NEWLIB}.tar.gz
fi
# cppcheck
if [ ! -f cppcheck-${PKG_CPPCHECK}.tar.gz ]; then
  wget -O "cppcheck-${PKG_CPPCHECK}.tar.gz" "https://github.com/danmar/cppcheck/archive/${PKG_CPPCHECK}.tar.gz"
  tar -xzf cppcheck-${PKG_CPPCHECK}.tar.gz
fi
# dtc
if [ ! -f dtc-${PKG_DTC}.tar.gz ]; then
  wget -O "dtc-${PKG_DTC}.tar.gz" "https://github.com/dgibson/dtc/archive/v${PKG_DTC}.tar.gz"
  tar -xzf dtc-${PKG_DTC}.tar.gz
fi
