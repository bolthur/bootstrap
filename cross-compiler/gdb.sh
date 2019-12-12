#!/bin/bash
set -ex

# Target
export TARGET=$1

# Get cpu count
if [[ "$OSTYPE" == "darwin"* ]]; then
  CPU_COUNT=$(sysctl -n hw.physicalcpu)
else
  CPU_COUNT=$(nproc)
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

  if [[ "$OSTYPE" == "darwin"* ]]; then
    ../../source/gdb-$PKG_GDB/configure \
      --target=$TARGET \
      --prefix="$PREFIX" \
      --with-gmp="$PREFIX" \
      --with-mpfr="$PREFIX" \
      --with-mpc="$PREFIX"
  else
    ../../source/gdb-$PKG_GDB/configure \
      --target=$TARGET \
      --prefix="$PREFIX"
  fi

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
