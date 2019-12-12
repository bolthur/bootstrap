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
LD_VERSION=$( "$PREFIX/bin/$TARGET-ld" --version 2>&1 | head -n1 | cut -d" " -f5- )
if [[ $LD_VERSION == $PKG_BINUTILS ]]; then
  exit 0
fi

# Create build directory
mkdir -p "$TARGET_COMPILE/build/binutils-$TARGET"

# configure binutils for target
if [ ! -f "$TARGET_COMPILE/build/binutils-$TARGET/crosscompiler.configured" ]; then
  cd "$TARGET_COMPILE/build/binutils-$TARGET"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    ../../source/binutils-$PKG_BINUTILS/configure --target=$TARGET \
      --prefix="$PREFIX" \
      --with-sysroot \
      --disable-nls \
      --disable-werror \
      --with-gmp="$PREFIX" \
      --with-mpfr="$PREFIX" \
      --with-mpc="$PREFIX" \
      --with-isl="$PREFIX"
  else
    ../../source/binutils-$PKG_BINUTILS/configure --target=$TARGET \
      --prefix="$PREFIX" \
      --with-sysroot \
      --disable-nls \
      --disable-werror
  fi

  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as configured
  touch "$TARGET_COMPILE/build/binutils-$TARGET/crosscompiler.configured"
fi

# build binutils for target
if [ ! -f "$TARGET_COMPILE/build/binutils-$TARGET/crosscompiler.built" ]; then
  cd "$TARGET_COMPILE/build/binutils-$TARGET"

  make all -j${CPU_COUNT}
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as built
  touch "$TARGET_COMPILE/build/binutils-$TARGET/crosscompiler.built"
fi

# install binutils for target
if [ ! -f "$TARGET_COMPILE/build/binutils-$TARGET/crosscompiler.installed" ]; then
  cd "$TARGET_COMPILE/build/binutils-$TARGET"

  make install
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as installed
  touch "$TARGET_COMPILE/build/binutils-$TARGET/crosscompiler.installed"
fi

# cleanup
rm -rf "$TARGET_COMPILE/build/binutils-$TARGET"
