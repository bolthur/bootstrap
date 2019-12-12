#!/bin/bash
set -ex

# Package Verions
export PKG_AUTOMAKE="1.11.6"
export PKG_AUTOMAKE_INSTALL="1.11"
export PKG_AUTOCONF="2.64"
export PKG_NEWLIB="3.1.0"

# Bunch of prefixes
export TOOL_PREFIX="/opt/bolthur/newlib"
export CROSS_PREFIX="/opt/bolthur/cross"
export SYSROOT_BASE="/opt/bolthur/sysroot"
export TARGET_COMPILE="/opt/bolthur/tool"
# Extend path for sub script calls
export PATH="$TOOL_PREFIX/bin:$CROSS_PREFIX/bin:$PATH"

# Get directory path
export BASEDIR="$( cd "$( dirname "$0" )" && pwd )"
export PATCHDIR="$BASEDIR/patch"

# Download everything
sh "$BASEDIR/newlib/download.sh"

# Build necessary newlib tools
sh "$BASEDIR/newlib/automake.sh"
sh "$BASEDIR/newlib/autoconf.sh"

# Build newlib
sh "$BASEDIR/newlib/newlib.sh" "arm-none-eabi" "arm-bolthur" "$SYSROOT_BASE/arm"
#sh "$BASEDIR/newlib/newlib.sh" "aarch64-none-elf" "aarch64-bolthur" "$SYSROOT_BASE/aarch64"
