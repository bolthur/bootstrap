#!/bin/bash
set -ex

# Package Verions
export PKG_BINUTILS="2.33.1"
export PKG_GCC="9.2.0"
export PKG_GMP="6.1.0"
export PKG_MPFR="3.1.4"
export PKG_MPC="1.0.3"
export PKG_ISL="0.18"
export PKG_GDB="8.3.1"

export PREFIX="/opt/bolthur/cross"
export TARGET_COMPILE="/opt/bolthur/tool"
# Extend path for sub script calls
export PATH="$PREFIX/bin:$PATH"

# Get directory path
BASEDIR="$( cd "$( dirname "$0" )" && pwd )"

# Download everything
sh "$BASEDIR/cross-compiler/download.sh"

# Build dependencies
sh "$BASEDIR/cross-compiler/dependency.sh"

# Binutils, gcc and gdb for arm-none-eabi
sh "$BASEDIR/cross-compiler/binutils.sh" "arm-none-eabi"
sh "$BASEDIR/cross-compiler/gcc.sh" "arm-none-eabi" "rmprofile,aprofile"
sh "$BASEDIR/cross-compiler/gdb.sh" "arm-none-eabi"
# Cleanup
sh "$BASEDIR/cross-compiler/cleanup.sh" "arm-none-eabi"

# Binutils, gcc and gdb for aarch64-none-elf
sh "$BASEDIR/cross-compiler/binutils.sh" "aarch64-none-elf"
sh "$BASEDIR/cross-compiler/gcc.sh" "aarch64-none-elf" "ilp32,lp64"
sh "$BASEDIR/cross-compiler/gdb.sh" "aarch64-none-elf"
# Cleanup
sh "$BASEDIR/cross-compiler/cleanup.sh" "aarch64-none-elf"

# Cleanup rest
rm -rf /tmp/toolchain
