#!/bin/bash
set -x

# check for already installed
LIBTOOL_VERSION=$( "$TOOL_PREFIX/bin/libtool" --version 2>&1 | head -n1 | cut -d" " -f4- )
if [[ $LIBTOOL_VERSION == $PKG_LIBTOOL ]]; then
  exit 0
fi

# Create build directory
mkdir -p "$TARGET_COMPILE/build/libtool-$PKG_LIBTOOL"

# apply necessary patches file by file
if [ ! -f "$TARGET_COMPILE/source/libtool-$PKG_LIBTOOL/libtool.patched" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/libtool-$PKG_LIBTOOL"
  # set patchdir
  LIBTOOL_PATCHDIR="$PATCHDIR/libtool/$PKG_LIBTOOL"
  EXPERIMENTAL_LIBTOOL_PATCHDIR="$PATCHDIR/.experimental/libtool/$PKG_LIBTOOL"
  # handle experimental / work in progress
  if [[ 1 == $EXPERIMENTAL ]] && [[ -d "$EXPERIMENTAL_LIBTOOL_PATCHDIR" ]]; then
    LIBTOOL_PATCHDIR=$EXPERIMENTAL_LIBTOOL_PATCHDIR
  fi
  # apply patches
  if [[ -d "$LIBTOOL_PATCHDIR" ]]; then
    # apply patch per patch
    for patch in $LIBTOOL_PATCHDIR/*; do
      patch -d $TARGET_COMPILE/source/libtool-$PKG_LIBTOOL -p0 < $patch
    done;
    # mark as patched
    touch "$TARGET_COMPILE/source/libtool-$PKG_LIBTOOL/libtool.patched"
  fi
fi

# configure libtool
if [ ! -f "$TARGET_COMPILE/source/libtool-$PKG_LIBTOOL/libtool.generated" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/libtool-$PKG_LIBTOOL"
  # reconfigure
  autoreconf
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as generated
  touch "$TARGET_COMPILE/source/libtool-$PKG_LIBTOOL/libtool.generated"
fi

# configure libtool
if [ ! -f "$TARGET_COMPILE/build/libtool-$PKG_LIBTOOL/libtool.configured" ]; then
  # switch to build directory
  cd "$TARGET_COMPILE/build/libtool-$PKG_LIBTOOL"
  # configure
  ../../source/libtool-$PKG_LIBTOOL/configure --prefix=$TOOL_PREFIX
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as configured
  touch "$TARGET_COMPILE/build/libtool-$PKG_LIBTOOL/libtool.configured"
fi

# build libtool for target
if [ ! -f "$TARGET_COMPILE/build/libtool-$PKG_LIBTOOL/libtool.built" ]; then
  # switch to build directory
  cd "$TARGET_COMPILE/build/libtool-$PKG_LIBTOOL"
  # build it
  make all -j${CPU_COUNT}
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as built
  touch "$TARGET_COMPILE/build/libtool-$PKG_LIBTOOL/libtool.built"
fi

# install binutils for target
if [ ! -f "$TARGET_COMPILE/build/libtool-$PKG_LIBTOOL/libtool.installed" ]; then
  # switch into build directory
  cd "$TARGET_COMPILE/build/libtool-$PKG_LIBTOOL"
  # install
  make install
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as installed
  touch "$TARGET_COMPILE/build/libtool-$PKG_LIBTOOL/libtool.installed"
fi

# cleanup
rm -rf "$TARGET_COMPILE/build/libtool-$PKG_LIBTOOL"
