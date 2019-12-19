#!/bin/bash
set -ex

export PREFIX_SUFFIX="newlib"
export CROSS_SUFFIX="cross"
export TOOL_PREFIX_SUFFIX="newlib"

. $(dirname "$0")/_base.sh
. $(dirname "$0")/_newlib.sh

# Download everything
sh "$BASEDIR/newlib/download.sh"

# Build necessary newlib tools
sh "$BASEDIR/_base/automake.sh"
sh "$BASEDIR/_base/autoconf.sh"

# Build newlib
sh "$BASEDIR/newlib/newlib.sh" "arm-none-eabi" "arm-bolthur-eabi" "$SYSROOT_BASE/arm"
#sh "$BASEDIR/newlib/newlib.sh" "aarch64-none-elf" "aarch64-bolthur-elf" "$SYSROOT_BASE/aarch64"
