#!/bin/bash
set -ex

# article with build order hint https://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/

# Package Verions
export PKG_BINUTILS="2.34"
export PKG_GCC="9.2.0"
export PKG_GDB="9.1"
export PKG_GLIBC="2.31"
export PKG_NEWLIB="3.1.0"

# Get directory path and patch dir
export BASEDIR="$( cd "$( dirname "$0" )" && pwd )"
export PATCHDIR="$BASEDIR/patch"

# prefix and path extension
export TARGET_COMPILE="/opt/bolthur/tool"
export PREFIX="/opt/bolthur/cross"
export PATH="$PREFIX/bin:$PATH"

# Get cpu count
if [[ "$OSTYPE" == "darwin"* ]]; then
  CPU_COUNT=$(sysctl -n hw.physicalcpu)
else
  CPU_COUNT=$(nproc)
fi

# target to build
export TARGET="arm-unknown-bolthur-eabi"

# Download everything
sh "$BASEDIR/download.sh"

# Build and install binutils
sh "$BASEDIR/binutils.sh"

# Build and install gcc executable
sh "$BASEDIR/gcc.sh" "stage1" "aprofile"

# Build and install newlib
sh "$BASEDIR/newlib.sh"

# Build and install libgcc
sh "$BASEDIR/gcc.sh" "stage2" "aprofile"

# Build and install gdb
sh "$BASEDIR/gdb.sh"

# FIXME: Add cleanup when gdb is added
## Cleanup
##rm -rf /opt/bolthur/tool
