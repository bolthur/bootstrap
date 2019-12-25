#!/bin/bash
set -ex

export PREFIX_SUFFIX="newlib-os-specific"
export CROSS_SUFFIX="os"
export TOOL_PREFIX_SUFFIX="newlib-os-specific"

. $(dirname "$0")/_base.sh
. $(dirname "$0")/_newlib.sh

# wipe out previous sysroot
#if [ -d "$SYSROOT_BASE" ]; then
#  rm -rf "$SYSROOT_BASE"
#fi

# Download everything
sh "$BASEDIR/newlib/download.sh"

# Build necessary newlib tools
sh "$BASEDIR/_base/automake.sh"
sh "$BASEDIR/_base/autoconf.sh"

# Build newlib
sh "$BASEDIR/newlib/newlib.sh" "arm-bolthur-eabi" "arm-bolthur-eabi" "$SYSROOT_BASE/arm" "rebuild"
#sh "$BASEDIR/newlib/newlib.sh" "aarch64-bolthur-elf" "aarch64-bolthur-elf" "$SYSROOT_BASE/aarch64"
