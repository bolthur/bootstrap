#!/bin/bash
set -x

# check for already installed
M4_VERSION=$( "$TOOL_PREFIX/bin/m4" --version 2>&1 | head -n1 | cut -d" " -f4- )
if [[ $M4_VERSION == $PKG_M4 ]]; then
  exit 0
fi

# Create build directory
mkdir -p "$TARGET_COMPILE/build/m4-$PKG_M4"

# apply necessary patches file by file
if [ ! -f "$TARGET_COMPILE/source/m4-$PKG_M4/m4.patched" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/m4-$PKG_M4"
  # set patchdir
  M4_PATCHDIR="$PATCHDIR/m4/$PKG_M4"
  EXPERIMENTAL_M4_PATCHDIR="$PATCHDIR/.experimental/m4/$PKG_M4"
  # handle experimental / work in progress
  if [[ 1 == $EXPERIMENTAL ]] && [[ -d "$EXPERIMENTAL_M4_PATCHDIR" ]]; then
    M4_PATCHDIR=$EXPERIMENTAL_M4_PATCHDIR
  fi
  # apply patches
  if [[ -d "$M4_PATCHDIR" ]]; then
    # apply patch per patch
    for patch in $M4_PATCHDIR/*; do
      patch -d $TARGET_COMPILE/source/m4-$PKG_M4 -p0 < $patch
    done;
    # mark as patched
    touch "$TARGET_COMPILE/source/m4-$PKG_M4/m4.patched"
  fi
fi

# configure m4
if [ ! -f "$TARGET_COMPILE/source/m4-$PKG_M4/m4.generated" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/m4-$PKG_M4"
  # reconfigure
  autoreconf
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as generated
  touch "$TARGET_COMPILE/source/m4-$PKG_M4/m4.generated"
fi

# configure m4
if [ ! -f "$TARGET_COMPILE/build/m4-$PKG_M4/m4.configured" ]; then
  # switch to build directory
  cd "$TARGET_COMPILE/build/m4-$PKG_M4"
  # configure
  ../../source/m4-$PKG_M4/configure --prefix=$TOOL_PREFIX
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as configured
  touch "$TARGET_COMPILE/build/m4-$PKG_M4/m4.configured"
fi

# build m4 for target
if [ ! -f "$TARGET_COMPILE/build/m4-$PKG_M4/m4.built" ]; then
  # switch to build directory
  cd "$TARGET_COMPILE/build/m4-$PKG_M4"
  # build it
  make all -j${CPU_COUNT}
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as built
  touch "$TARGET_COMPILE/build/m4-$PKG_M4/m4.built"
fi

# install binutils for target
if [ ! -f "$TARGET_COMPILE/build/m4-$PKG_M4/m4.installed" ]; then
  # switch into build directory
  cd "$TARGET_COMPILE/build/m4-$PKG_M4"
  # install
  make install
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as installed
  touch "$TARGET_COMPILE/build/m4-$PKG_M4/m4.installed"
fi

# cleanup
rm -rf "$TARGET_COMPILE/build/m4-$PKG_M4"
