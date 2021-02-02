#!/bin/bash
set -x

# Create directory for source files
mkdir -p "$TARGET_COMPILE/source"
cd "$TARGET_COMPILE/source"

# binutils ( download & extract )
if [[ ! -f binutils-$PKG_BINUTILS.tar.gz ]]; then
  wget "https://ftp.gnu.org/gnu/binutils/binutils-${PKG_BINUTILS}.tar.gz"
fi
if [[ -d "binutils-${PKG_BINUTILS}" ]] && [[ 1 == $REBUILD_BINUTILS ]]; then
  rm -rf "binutils-${PKG_BINUTILS}"
fi
if [[ ! -d "binutils-${PKG_BINUTILS}" ]]; then
  tar -xzf binutils-${PKG_BINUTILS}.tar.gz
fi
## gcc ( download & extract )
if [[ ! -f gcc-$PKG_GCC.tar.gz ]]; then
  wget "https://ftp.gnu.org/gnu/gcc/gcc-${PKG_GCC}/gcc-${PKG_GCC}.tar.gz"
fi
if [[ -d "gcc-${PKG_GCC}" ]] && [[ 1 == $REBUILD_GCC ]]; then
  rm -rf "gcc-${PKG_GCC}"
fi
if [[ ! -d "gcc-${PKG_GCC}" ]]; then
  tar -xzf gcc-${PKG_GCC}.tar.gz
fi
# gdb ( download & extract )
if [[ ! -f gdb-$PKG_GDB.tar.gz ]]; then
  wget "https://ftp.gnu.org/gnu/gdb/gdb-${PKG_GDB}.tar.gz"
fi
if [[ -d "gdb-${PKG_GDB}" ]] && [[ 1 == $REBUILD_GDB ]]; then
  rm -rf "gdb-${PKG_GDB}"
fi
if [[ ! -d "gdb-${PKG_GDB}" ]]; then
  tar -xzf gdb-${PKG_GDB}.tar.gz
fi
# glibc ( download & extract )
if [[ ! -f glibc-$PKG_GLIBC.tar.gz ]]; then
  wget "https://ftp.gnu.org/gnu/libc/glibc-${PKG_GLIBC}.tar.gz"
fi
# FIXME: ADD AGAIN WITH PROPER GLIBC PATCH AND REBUILD SUPPORT
# if [[ -d "glibc-${PKG_GLIBC}" ]]; then
#   rm -rf "glibc-${PKG_GLIBC}"
# fi
if [[ ! -d "glibc-${PKG_GLIBC}" ]]; then
  tar -xzf glibc-${PKG_GLIBC}.tar.gz
fi
# newlib ( download & extract )
if [[ ! -f newlib-${PKG_NEWLIB}.tar.gz ]]; then
  wget "https://www.sourceware.org/pub/newlib/newlib-${PKG_NEWLIB}.tar.gz"
fi
if [[ -d "newlib-${PKG_NEWLIB}" ]] && [[ 1 == $REBUILD_NEWLIB ]]; then
  rm -rf "newlib-${PKG_NEWLIB}"
fi
if [[ ! -d "newlib-${PKG_NEWLIB}" ]]; then
  tar -xzf newlib-${PKG_NEWLIB}.tar.gz
fi
# cppcheck ( download & extract )
if [[ ! -f cppcheck-${PKG_CPPCHECK}.tar.gz ]]; then
  wget -O "cppcheck-${PKG_CPPCHECK}.tar.gz" "https://github.com/danmar/cppcheck/archive/${PKG_CPPCHECK}.tar.gz"
fi
# FIXME: ADD AGAIN WITH PROPER REBUILD SUPPORT
# if [[ -d "cppcheck-${PKG_CPPCHECK}" ]]; then
#   rm -rf "cppcheck-${PKG_CPPCHECK}"
# fi
if [[ ! -d "cppcheck-${PKG_CPPCHECK}" ]]; then
  tar -xzf cppcheck-${PKG_CPPCHECK}.tar.gz
fi
# dtc ( download & extract )
if [[ ! -f dtc-${PKG_DTC}.tar.gz ]]; then
  wget -O "dtc-${PKG_DTC}.tar.gz" "https://github.com/dgibson/dtc/archive/v${PKG_DTC}.tar.gz"
fi
if [[ -d "dtc-${PKG_DTC}" ]]; then
  rm -rf "dtc-${PKG_DTC}"
fi
if [[ ! -d "dtc-${PKG_DTC}" ]]; then
  tar -xzf dtc-${PKG_DTC}.tar.gz
fi
