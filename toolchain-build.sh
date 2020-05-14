#!/bin/bash
set -ex

# Package Verions
export PKG_BINUTILS="2.34"
export PKG_GCC="10.1.0"
export PKG_GDB="9.1"
export PKG_GLIBC="2.31"
export PKG_NEWLIB="3.3.0"
export PKG_CPPCHECK="2.0"
export PKG_DTC="1.6.0"

# Get directory path and patch dir
export BASEDIR="$( cd "$( dirname "$0" )" && pwd )"
export PATCHDIR="$BASEDIR/patch"
export PREFIX_BASE="/opt/bolthur"
export BUILD_TARGET=

# consider possible prefix option
while getopts ":p:t:" opt; do
  case $opt in
    p) PREFIX_BASE="$OPTARG"
    ;;
    t) BUILD_TARGET="$OPTARG"
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

# Download everything
sh "$BASEDIR/download.sh"

# Build and install device tree tools
DTC_VERSION=$( "$PREFIX/bin/dtc" --version 2>&1 | head -n1 | cut -d" " -f3- )
if [[ $DTC_VERSION != $PKG_DTC ]]; then
  sh "$BASEDIR/dtc.sh"
fi


# Build and install cppcheck if not installed
CPPCHECK_VERSION=$( "$PREFIX/bin/cppcheck" --version 2>&1 | head -n1 | cut -d" " -f2- )
if [[ $CPPCHECK_VERSION != $PKG_CPPCHECK ]]; then
  sh "$BASEDIR/cppcheck.sh"
fi

# handle specific build
if [[ ! -z $BUILD_TARGET && -f "$BASEDIR/target/$BUILD_TARGET.sh" ]]; then
  # build wanted target
  . $BASEDIR/target/$BUILD_TARGET.sh
  sh "$BASEDIR/build.sh"
else
  # build arm toolchain
  . $BASEDIR/target/arm.sh
  sh "$BASEDIR/build.sh"
  ## build aarch64 toolchain
  #. $BASEDIR/target/aarch64.sh
  #sh "$BASEDIR/build.sh"
fi

## Cleanup everything unnecessary
rm -rf "$TARGET_COMPILE"
