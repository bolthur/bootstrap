#!/bin/bash
set -x



# internal dependencies
export PKG_AUTOMAKE="1.15.1"
export PKG_AUTOMAKE_INSTALL="1.15"
export PKG_AUTOCONF="2.69"
export PKG_LIBTOOL="2.4.6"
export PKG_M4="1.4.18"
# download
sh "$BASEDIR/download-internal.sh"
# tool prefix
export TOOL_PREFIX="/opt/bolthur/tool/binutils-$TARGET"
# automake and autoconf
sh "$BASEDIR/autotools/m4.sh"
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi
sh "$BASEDIR/autotools/autoconf.sh"
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi
sh "$BASEDIR/autotools/automake.sh"
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi
sh "$BASEDIR/autotools/libtool.sh"
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi
# Extend path for sub script calls
export PATH="$TOOL_PREFIX/bin:$PATH"


export SHARED=$1

export ADDITIONAL_FLAG="--disable-shared"
if [[ 1 == $EXPERIMENTAL ]] && [[ "$SHARED" == "shared"* ]]; then
  export ADDITIONAL_FLAG="--enable-shared"
fi

# Handle rebuild
if [[ -d "$TARGET_COMPILE/build/binutils-$TARGET" ]] && [[ 1 == $REBUILD_BINUTILS ]]; then
  rm -rf "$TARGET_COMPILE/build/binutils-$TARGET"
fi
# Create build directory
mkdir -p "$TARGET_COMPILE/build/binutils-$TARGET"

# apply necessary patches file by file
if [ ! -f "$TARGET_COMPILE/source/binutils-$PKG_BINUTILS/binutils.patched" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/binutils-$PKG_BINUTILS"
  # set patch directories
  BINUTIL_PATCHDIR="$PATCHDIR/binutils/$PKG_BINUTILS"
  EXPERIMENTAL_BINUTIL_PATCHDIR="$PATCHDIR/.experimental/binutils/$PKG_BINUTILS"
  # handle experimental / work in progress
  if [[ 1 == $EXPERIMENTAL ]] && [[ -d "$EXPERIMENTAL_BINUTIL_PATCHDIR" ]]; then
    BINUTIL_PATCHDIR=$EXPERIMENTAL_BINUTIL_PATCHDIR
  fi
  # apply patch
  if [[ -d "$BINUTIL_PATCHDIR" ]]; then
    for patch in $BINUTIL_PATCHDIR/*; do
      patch -d $TARGET_COMPILE/source/binutils-$PKG_BINUTILS -p0 < $patch
    done;
    # mark as patched
    touch "$TARGET_COMPILE/source/binutils-$PKG_BINUTILS/binutils.patched"
  fi
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
if [ ! -f "$TARGET_COMPILE/build/binutils-$TARGET/binutils.configured" ]; then
  cd "$TARGET_COMPILE/build/binutils-$TARGET"

  ../../source/binutils-$PKG_BINUTILS/configure \
    --target=$TARGET \
    --prefix="$PREFIX" \
    --disable-nls \
    --disable-werror \
    --disable-libssp \
    --with-sysroot=$SYSROOT/$TARGET \
    --with-pkgversion="GNU Binutils; bolthur bootstrap cross" \
    $ADDITIONAL_FLAG

  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as configured
  touch "$TARGET_COMPILE/build/binutils-$TARGET/binutils.configured"
fi

# build binutils for target
if [ ! -f "$TARGET_COMPILE/build/binutils-$TARGET/binutils.built" ]; then
  cd "$TARGET_COMPILE/build/binutils-$TARGET"

  make -j${CPU_COUNT}
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as built
  touch "$TARGET_COMPILE/build/binutils-$TARGET/binutils.built"
fi

# install binutils for target
if [ ! -f "$TARGET_COMPILE/build/binutils-$TARGET/binutils.installed" ]; then
  cd "$TARGET_COMPILE/build/binutils-$TARGET"

  make install-strip
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as installed
  touch "$TARGET_COMPILE/build/binutils-$TARGET/binutils.installed"
fi
