#!/bin/bash
set -ex

# Target
export TARGET=$1
export MULTILIB_LIST=$2
export MULTILIB=""

# Get cpu count
if [[ "$OSTYPE" == "darwin"* ]]; then
  CPU_COUNT=$(sysctl -n hw.physicalcpu)
else
  CPU_COUNT=$(nproc)
fi

# check for already installed
GCC_VERSION=$( "$PREFIX/bin/$TARGET-gcc" --version 2>&1 | head -n1 | cut -d" " -f3- )
if [[ $GCC_VERSION == $PKG_GCC ]]; then
  exit 0
fi

# add multilib parameter if set
if [ -n "$MULTILIB_LIST" ]; then
  export MULTILIB="--with-multilib-list=$MULTILIB_LIST"
fi

# Create build directory
mkdir -p "$TARGET_COMPILE/build/gcc-$TARGET"

# configure gcc for target
if [ ! -f "$TARGET_COMPILE/build/gcc-$TARGET/crosscompiler.configured" ]; then
  cd "$TARGET_COMPILE/build/gcc-$TARGET"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    ../../source/gcc-$PKG_GCC/configure \
      --target=$TARGET \
      --prefix="$PREFIX" \
      --disable-nls \
      --enable-languages=c,c++ \
      --without-headers \
      --with-gmp="$PREFIX" \
      --with-mpfr="$PREFIX" \
      --with-mpc="$PREFIX" \
      $MULTILIB
  else
    ../../source/gcc-$PKG_GCC/configure \
      --target=$TARGET \
      --prefix="$PREFIX" \
      --disable-nls \
      --enable-languages=c,c++ \
      --without-headers \
      $MULTILIB
  fi

  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as configured
  touch "$TARGET_COMPILE/build/gcc-$TARGET/crosscompiler.configured"
fi
# build gcc for target
if [ ! -f "$TARGET_COMPILE/build/gcc-$TARGET/crosscompiler.built" ]; then
  cd "$TARGET_COMPILE/build/gcc-$TARGET"

  make all-gcc -j${CPU_COUNT}
  if [ $? -ne 0 ]; then
    exit 1
  fi

  make all-target-libgcc -j${CPU_COUNT}
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as built
  touch "$TARGET_COMPILE/build/gcc-$TARGET/crosscompiler.built"
fi
# install gcc for target
if [ ! -f "$TARGET_COMPILE/build/gcc-$TARGET/crosscompiler.installed" ]; then
  cd "$TARGET_COMPILE/build/gcc-$TARGET"

  make install-gcc
  if [ $? -ne 0 ]; then
    exit 1
  fi

  make install-target-libgcc
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as installed
  touch "$TARGET_COMPILE/build/gcc-$TARGET/crosscompiler.installed"
fi

# cleanup
rm -rf "$TARGET_COMPILE/build/gcc-$TARGET"
