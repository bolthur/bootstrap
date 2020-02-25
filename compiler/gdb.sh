#!/bin/bash
set -ex

# Target
export TARGET=$1
export SYSROOT=$2

# Get cpu count
if [[ "$OSTYPE" == "darwin"* ]]; then
  CPU_COUNT=$(sysctl -n hw.physicalcpu)
else
  CPU_COUNT=$(nproc)
fi

export SYSROOT_OPTION=""
if [ ! -z $SYSROOT ]; then
  export SYSROOT_OPTION=" \
    --with-sysroot=$SYSROOT"
  # Change prefix to sysroot
  export PREFIX=$SYSROOT
  # Extend path for sub script calls
  export PATH="$PREFIX/bin:$PATH"
fi

# check for already installed
GDB_VERSION=$( "$PREFIX/bin/$TARGET-gdb" --version 2>&1 | head -n1 | cut -d" " -f4- )
if [[ $GDB_VERSION == $PKG_GDB ]]; then
  exit 0
fi

# Create build directory
mkdir -p "$TARGET_COMPILE/build/gdb-$TARGET"

# configure gdb for target
if [ ! -f "$TARGET_COMPILE/build/gdb-$TARGET/crosscompiler.configured" ]; then
  cd "$TARGET_COMPILE/build/gdb-$TARGET"

  ../../source/gdb-$PKG_GDB/configure \
    --target=$TARGET \
    --prefix="$PREFIX" \
    $SYSROOT_OPTION

  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as configured
  touch "$TARGET_COMPILE/build/gdb-$TARGET/crosscompiler.configured"
fi
# build gdb for target
if [ ! -f "$TARGET_COMPILE/build/gdb-$TARGET/crosscompiler.built" ]; then
  cd "$TARGET_COMPILE/build/gdb-$TARGET"

  make all -j${CPU_COUNT}
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as built
  touch "$TARGET_COMPILE/build/gdb-$TARGET/crosscompiler.built"
fi
# install gdb for target
if [ ! -f "$TARGET_COMPILE/build/gdb-$TARGET/crosscompiler.installed" ]; then
  cd "$TARGET_COMPILE/build/gdb-$TARGET"

  make install
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as installed
  touch "$TARGET_COMPILE/build/gdb-$TARGET/crosscompiler.installed"
fi

# cleanup
rm -rf "$TARGET_COMPILE/build/gdb-$TARGET"
