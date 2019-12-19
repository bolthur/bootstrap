#!/bin/bash
set -ex

# Create directory for source files
mkdir -p "$TARGET_COMPILE/source"
cd "$TARGET_COMPILE/source"

# download additionally possible required packages
if [[ "$OSTYPE" == "darwin"* ]]; then
  # gmp
  if [ ! -f gmp-$PKG_GMP.tar.bz2 ]; then
    wget "https://gcc.gnu.org/pub/gcc/infrastructure/gmp-${PKG_GMP}.tar.bz2"
    tar -xjf gmp-$PKG_GMP.tar.bz2
  fi
  # mpfr
  if [ ! -f mpfr-$PKG_MPFR.tar.bz2 ]; then
    wget "https://gcc.gnu.org/pub/gcc/infrastructure/mpfr-${PKG_MPFR}.tar.bz2"
    tar -xjf mpfr-$PKG_MPFR.tar.bz2
  fi
  # mpc
  if [ ! -f mpc-$PKG_MPC.tar.gz ]; then
    wget "https://gcc.gnu.org/pub/gcc/infrastructure/mpc-${PKG_MPC}.tar.gz"
    tar -xzf mpc-$PKG_MPC.tar.gz
  fi
  # isl
  if [ ! -f isl-$PKG_ISL.tar.bz2 ]; then
    wget "https://gcc.gnu.org/pub/gcc/infrastructure/isl-${PKG_ISL}.tar.bz2"
    tar -xjf isl-${PKG_ISL}.tar.bz2
  fi
fi
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
