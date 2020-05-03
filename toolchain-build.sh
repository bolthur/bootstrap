#!/bin/bash
set -ex

# Package Verions
export PKG_BINUTILS="2.34"
export PKG_GCC="9.2.0"
export PKG_GDB="9.1"
export PKG_GLIBC="2.31"
export PKG_NEWLIB="3.3.0"
export PKG_CPPCHECK="1.90"

# Get directory path and patch dir
export BASEDIR="$( cd "$( dirname "$0" )" && pwd )"
export PATCHDIR="$BASEDIR/patch"

# consider possible prefix option
while getopts ":p:" opt; do
  case $opt in
    p) PREFIX_BASE="$OPTARG"
    ;;
    \?) PREFIX_BASE="/opt/bolthur"
    ;;
  esac
done

# prefix and path extension
export TARGET_COMPILE="$PREFIX_BASE/tool"
export PREFIX="$PREFIX_BASE/cross"
export PATH="$PREFIX/bin:$PATH"
export SYSROOT="$PREFIX_BASE/sysroot"

# Get cpu count
if [[ "$OSTYPE" == "darwin"* ]]; then
  export CPU_COUNT=$(sysctl -n hw.physicalcpu)
else
  export CPU_COUNT=$(nproc)
fi

# target to build
export TARGET="arm-unknown-bolthur-eabi"

# Download everything
sh "$BASEDIR/download.sh"

# Build and install cppcheck if not installed
CPPCHECK_VERSION=$( "$PREFIX/bin/cppcheck" --version 2>&1 | head -n1 | cut -d" " -f2- )
if [[ $CPPCHECK_VERSION != $PKG_CPPCHECK ]]; then
  sh "$BASEDIR/cppcheck.sh"
fi

# Build and install binutils if not installed
LD_VERSION=$( "$PREFIX/bin/$TARGET-ld" --version 2>&1 | head -n1 | cut -d" " -f8- )
if [[ $LD_VERSION != $PKG_BINUTILS ]]; then
  sh "$BASEDIR/binutils.sh"
fi

# check for installed gcc
GCC_VERSION=$( "$PREFIX/bin/$TARGET-gcc" --version 2>&1 | head -n1 | cut -d" " -f6- )
# default = install gcc
GCC_INSTALL=1;
if [[ $GCC_VERSION == $PKG_GCC ]]; then
  # check for libgcc.a if gcc is installed
  LIBGCC=$( "$PREFIX/bin/$TARGET-gcc" --print-file-name=libgcc.a 2>&1 | head -n1 )
  # reset GCC_INSTALL if libgcc is existing
  if [ -f "$LIBGCC" ]; then
    GCC_INSTALL=0
  fi
fi

if [[ 1 == $GCC_INSTALL ]]; then
  # Build and install gcc executable
  sh "$BASEDIR/gcc.sh" "stage1" "aprofile"

  # Build and install newlib
  sh "$BASEDIR/newlib.sh"

  # Build and install libgcc
  sh "$BASEDIR/gcc.sh" "stage2" "aprofile"
fi

# Build and install gdb if not installed
GDB_VERSION=$( "$PREFIX/bin/$TARGET-gdb" --version 2>&1 | head -n1 | cut -d" " -f4- )
if [[ -z "$TRAVIS" && $GDB_VERSION != $PKG_GDB ]]; then
  sh "$BASEDIR/gdb.sh"
fi

# Cleanup everything unnecessary
rm -rf "$TARGET_COMPILE"
