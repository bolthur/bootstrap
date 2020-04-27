#!/bin/bash
set -ex



# internal dependencies
export PKG_AUTOMAKE="1.15.1"
export PKG_AUTOMAKE_INSTALL="1.15"
export PKG_AUTOCONF="2.69"
# download
sh "$BASEDIR/download-internal.sh"
# tool prefix
export TOOL_PREFIX="/opt/bolthur/tool/binutils-$TARGET"
# Extend path for sub script calls
export PATH="$TOOL_PREFIX/bin:$PATH"
# automake and autoconf
sh "$BASEDIR/automake.sh"
sh "$BASEDIR/autoconf.sh"



# Create build directory
mkdir -p "$TARGET_COMPILE/build/binutils-$TARGET"

# apply necessary patches file by file
if [ ! -f "$TARGET_COMPILE/source/binutils-$PKG_BINUTILS/binutils.patched" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/binutils-$PKG_BINUTILS"
  # set patchdir
  BINTUIL_PATCHDIR="$PATCHDIR/binutils/$PKG_BINUTILS"
  # apply patch per patch
  if [ -d $BINTUIL_PATCHDIR ]; then
    for patch in $BINTUIL_PATCHDIR/*; do
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
    --with-sysroot=$SYSROOT/$TARGET \
    --with-pkgversion="GNU Binutils; bolthur bootstrap cross"

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
