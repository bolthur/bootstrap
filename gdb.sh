#!/bin/bash
set -ex

# Create build directory
mkdir -p "$TARGET_COMPILE/build/gdb-$TARGET"

# apply necessary patches file by file
if [ ! -f "$TARGET_COMPILE/source/gdb-$PKG_GDB/gdb.patched" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/gdb-$PKG_GDB"
  # set patchdir
  GDB_PATCHDIR="$PATCHDIR/gdb/$PKG_GDB"
  if [ -d $GDB_PATCHDIR ]; then
    # apply patch per patch
    for patch in $GDB_PATCHDIR/*; do
      patch -d $TARGET_COMPILE/source/gdb-$PKG_GDB -p0 < $patch
    done;
    # mark as patched
    touch "$TARGET_COMPILE/source/gdb-$PKG_GDB/gdb.patched"
  fi
fi

# configure gdb for target
if [ ! -f "$TARGET_COMPILE/build/gdb-$TARGET/gdb.configured" ]; then
  cd "$TARGET_COMPILE/build/gdb-$TARGET"

  ../../source/gdb-$PKG_GDB/configure \
    --target=$TARGET \
    --prefix="$PREFIX"

  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as configured
  touch "$TARGET_COMPILE/build/gdb-$TARGET/gdb.configured"
fi

# build gdb for target
if [ ! -f "$TARGET_COMPILE/build/gdb-$TARGET/gdb.built" ]; then
  cd "$TARGET_COMPILE/build/gdb-$TARGET"

  make all -j${CPU_COUNT}
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as built
  touch "$TARGET_COMPILE/build/gdb-$TARGET/gdb.built"
fi

# install gdb for target
if [ ! -f "$TARGET_COMPILE/build/gdb-$TARGET/gdb.installed" ]; then
  cd "$TARGET_COMPILE/build/gdb-$TARGET"

  make install -j${CPU_COUNT}
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as installed
  touch "$TARGET_COMPILE/build/gdb-$TARGET/gdb.installed"
fi
