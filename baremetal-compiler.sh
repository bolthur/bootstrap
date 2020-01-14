#!/bin/bash
set -ex

export PREFIX_SUFFIX="cross"
export TOOL_PREFIX_SUFFIX="cross"

. $(dirname "$0")/_base.sh

sh "$BASEDIR/binutils.sh" "arm-none-eabi"
#sh "$BASEDIR/binutils.sh" "aarch64-none-elf"

. $(dirname "$0")/_compiler.sh

# Download everything
sh "$BASEDIR/compiler/download.sh"

# Binutils, gcc and gdb for arm-none-eabi
sh "$BASEDIR/compiler/gcc.sh" "arm-none-eabi" "rmprofile,aprofile"
sh "$BASEDIR/compiler/gdb.sh" "arm-none-eabi"

## Binutils, gcc and gdb for aarch64-none-elf
#sh "$BASEDIR/compiler/binutils.sh" "aarch64-none-elf"
#sh "$BASEDIR/compiler/gcc.sh" "aarch64-none-elf" "ilp32,lp64"
#sh "$BASEDIR/compiler/gdb.sh" "aarch64-none-elf"
## Cleanup
#sh "$BASEDIR/compiler/cleanup.sh" "aarch64-none-elf"
