#!/bin/bash
set -ex

# check for already installed
AUTOMAKE_VERSION=$( "$TOOL_PREFIX/bin/automake" --version 2>&1 | head -n1 | cut -d" " -f4- )
if [[ $AUTOMAKE_VERSION == $PKG_AUTOMAKE ]]; then
  exit 0
fi

# Create build directory
mkdir -p "$TARGET_COMPILE/build/automake-$PKG_AUTOMAKE"

# apply necessary patches file by file
if [ ! -f "$TARGET_COMPILE/source/automake-$PKG_AUTOMAKE/automake.patched" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/automake-$PKG_AUTOMAKE"
  # set patchdir
  AUTOMAKE_PATCHDIR="$PATCHDIR/automake/$PKG_AUTOMAKE"
  if [ -d $AUTOMAKE_PATCHDIR ]; then
    # apply patch per patch
    for patch in $AUTOMAKE_PATCHDIR/*; do
      patch -d $TARGET_COMPILE/source/automake-$PKG_AUTOMAKE -p0 < $patch
    done;
    # mark as patched
    touch "$TARGET_COMPILE/source/automake-$PKG_AUTOMAKE/automake.patched"
  fi
fi

# apply necessary patches file by file
if [ ! -f "$TARGET_COMPILE/source/automake-$PKG_AUTOMAKE/automake.patched" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/automake-$PKG_AUTOMAKE"
  # set patchdir
  AUTOMAKE_PATCHDIR="$PATCHDIR/automake/$PKG_AUTOMAKE"
  # apply patch per patch
  if [ -d $AUTOMAKE_PATCHDIR ]; then
    for patch in $AUTOMAKE_PATCHDIR/*; do
      patch -d $TARGET_COMPILE/source/automake-$PKG_AUTOMAKE -p0 < $patch
    done;
    # mark as patched
    touch "$TARGET_COMPILE/source/automake-$PKG_AUTOMAKE/automake.patched"
  fi
fi

# configure automake
if [ ! -f "$TARGET_COMPILE/build/automake-$PKG_AUTOMAKE/automake.configured" ]; then
  # switch to build directory
  cd "$TARGET_COMPILE/build/automake-$PKG_AUTOMAKE"
  # configure
  ../../source/automake-$PKG_AUTOMAKE/configure --prefix=$TOOL_PREFIX
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as configured
  touch "$TARGET_COMPILE/build/automake-$PKG_AUTOMAKE/automake.configured"
fi

# build automake for target
if [ ! -f "$TARGET_COMPILE/build/automake-$PKG_AUTOMAKE/automake.built" ]; then
  # switch to build directory
  cd "$TARGET_COMPILE/build/automake-$PKG_AUTOMAKE"
  # build it
  make all -j${CPU_COUNT}
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as built
  touch "$TARGET_COMPILE/build/automake-$PKG_AUTOMAKE/automake.built"
fi

# install binutils for target
if [ ! -f "$TARGET_COMPILE/build/automake-$PKG_AUTOMAKE/automake.installed" ]; then
  # switch into build directory
  cd "$TARGET_COMPILE/build/automake-$PKG_AUTOMAKE"
  # install
  make install
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # switch to dir
  cd $TOOL_PREFIX/share
  # mark as installed
  touch "$TARGET_COMPILE/build/automake-$PKG_AUTOMAKE/automake.installed"
fi

# symlink
if [ ! -d "$TOOL_PREFIX/share/automake" ]; then
  ln -s "$TOOL_PREFIX/share/automake-$PKG_AUTOMAKE_INSTALL" automake
fi
if [ ! -d "$TOOL_PREFIX/share/aclocal" ]; then
  ln -s "$TOOL_PREFIX/share/aclocal-$PKG_AUTOMAKE_INSTALL" aclocal
fi

# cleanup
rm -rf "$TARGET_COMPILE/build/automake-$PKG_AUTOMAKE"
