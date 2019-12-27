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

export SYSROOT_OPTION="--with-sysroot"
if [ ! -z $SYSROOT ]; then
  export SYSROOT_OPTION="--with-sysroot=$SYSROOT"
  # Change prefix to sysroot
  export PREFIX=$SYSROOT
  # Extend path for sub script calls
  export PATH="$PREFIX/bin:$PATH"
fi

# check for already installed
LD_VERSION=$( "$PREFIX/bin/$TARGET-ld" --version 2>&1 | head -n1 | cut -d" " -f5- )
if [[ $LD_VERSION == $PKG_BINUTILS ]]; then
  exit 0
fi

# Create build directory
mkdir -p "$TARGET_COMPILE/build/binutils-$TARGET"

# apply necessary patches file by file
if [ ! -f "$TARGET_COMPILE/source/binutils-$PKG_BINUTILS/binutils.patched" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/binutils-$PKG_BINUTILS"
  # set patchdir
  BINTUIL_PATCHDIR="$PATCHDIR/binutils-$PKG_BINUTILS"
  # apply patch per patch
  for patch in $BINTUIL_PATCHDIR/*; do
    patch -d $TARGET_COMPILE/source/binutils-$PKG_BINUTILS -p0 < $patch
  done;
  # mark as patched
  touch "$TARGET_COMPILE/source/binutils-$PKG_BINUTILS/binutils.patched"
fi

# configure automake
if [ ! -f "$TARGET_COMPILE/source/binutils-$PKG_BINUTILS/binutils.generated" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/binutils-$PKG_BINUTILS/ld"
  # reconfigure
  automake
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as generated
  touch "$TARGET_COMPILE/source/binutils-$PKG_BINUTILS/binutils.generated"
fi

# configure binutils for target
if [ ! -f "$TARGET_COMPILE/build/binutils-$TARGET/crosscompiler.configured" ]; then
  cd "$TARGET_COMPILE/build/binutils-$TARGET"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    ../../source/binutils-$PKG_BINUTILS/configure --target=$TARGET \
      --prefix="$PREFIX" \
      $SYSROOT_OPTION \
      --disable-nls \
      --disable-werror \
      --with-gmp="$PREFIX" \
      --with-mpfr="$PREFIX" \
      --with-mpc="$PREFIX" \
      --with-isl="$PREFIX"
  else
    ../../source/binutils-$PKG_BINUTILS/configure --target=$TARGET \
      --prefix="$PREFIX" \
      $SYSROOT_OPTION \
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

  make all-binutils all-gas all-ld -j${CPU_COUNT}
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as built
  touch "$TARGET_COMPILE/build/binutils-$TARGET/crosscompiler.built"
fi

# install binutils for target
if [ ! -f "$TARGET_COMPILE/build/binutils-$TARGET/crosscompiler.installed" ]; then
  cd "$TARGET_COMPILE/build/binutils-$TARGET"

  make install-binutils install-gas install-ld
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as installed
  touch "$TARGET_COMPILE/build/binutils-$TARGET/crosscompiler.installed"
fi

# cleanup
rm -rf "$TARGET_COMPILE/build/binutils-$TARGET"
