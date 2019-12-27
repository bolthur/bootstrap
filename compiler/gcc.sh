#!/bin/bash
set -ex

# Target
export TARGET=$1
export MULTILIB_LIST=$2
export SYSROOT=$3
export MULTILIB=""

# Get cpu count
if [[ "$OSTYPE" == "darwin"* ]]; then
  CPU_COUNT=$(sysctl -n hw.physicalcpu)
else
  CPU_COUNT=$(nproc)
fi

export SYSROOT_OPTION="--without-headers\
  --disable-shared"
if [ ! -z $SYSROOT ]; then
  export SYSROOT_OPTION="$SYSROOT_OPTION \
    --with-sysroot=$SYSROOT \
    --with-newlib \
    --disable-werror"
  # Change prefix to sysroot
  export PREFIX=$SYSROOT
  # Extend path for sub script calls
  export PATH="$PREFIX/bin:$PATH"
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

# apply necessary patches file by file
if [ ! -f "$TARGET_COMPILE/source/gcc-$PKG_GCC/gcc.patched" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/gcc-$PKG_GCC"
  # set patchdir
  GCC_PATCHDIR="$PATCHDIR/gcc-$PKG_GCC"
  # apply patch per patch
  for patch in $GCC_PATCHDIR/*; do
    patch -d $TARGET_COMPILE/source/gcc-$PKG_GCC -p0 < $patch
  done;
  # mark as patched
  touch "$TARGET_COMPILE/source/gcc-$PKG_GCC/gcc.patched"
fi

# configure gcc
if [ ! -f "$TARGET_COMPILE/source/gcc-$PKG_GCC/gcc.generated" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/gcc-$PKG_GCC/libstdc++-v3"
  # reconfigure
  autoconf
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # switch to source directory
  cd "$TARGET_COMPILE/source/gcc-$PKG_GCC/gcc"
  # reconfigure
  autoconf
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as generated
  touch "$TARGET_COMPILE/source/gcc-$PKG_GCC/gcc.generated"
fi

# configure gcc for target
if [ ! -f "$TARGET_COMPILE/build/gcc-$TARGET/crosscompiler.configured" ]; then
  cd "$TARGET_COMPILE/build/gcc-$TARGET"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    ../../source/gcc-$PKG_GCC/configure \
      --target=$TARGET \
      --prefix="$PREFIX" \
      --disable-nls \
      --enable-languages=c,c++ \
      --with-gmp="$PREFIX" \
      --with-mpfr="$PREFIX" \
      --with-mpc="$PREFIX" \
      $MULTILIB \
      $SYSROOT_OPTION
  else
    ../../source/gcc-$PKG_GCC/configure \
      --target=$TARGET \
      --prefix="$PREFIX" \
      --disable-nls \
      --enable-languages=c,c++ \
      $MULTILIB \
      $SYSROOT_OPTION
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

  #if [ ! -z $SYSROOT ]; then
  #  make all-target-libstdc++-v3 -j${CPU_COUNT}
  #  if [ $? -ne 0 ]; then
  #    exit 1
  #  fi
  #fi

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

  #if [ ! -z $SYSROOT ]; then
  #  make install-target-libstdc++-v3
  #  if [ $? -ne 0 ]; then
  #    exit 1
  #  fi
  #fi

  # mark as installed
  touch "$TARGET_COMPILE/build/gcc-$TARGET/crosscompiler.installed"
fi

# cleanup
#rm -rf "$TARGET_COMPILE/build/gcc-$TARGET"
