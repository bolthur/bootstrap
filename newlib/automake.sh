#!/bin/bash
set -ex

# Get cpu count
if [[ "$OSTYPE" == "darwin"* ]]; then
  CPU_COUNT=$(sysctl -n hw.physicalcpu)
else
  CPU_COUNT=$(nproc)
fi

# check for already installed
AUTOMAKE_VERSION=$( "$TOOL_PREFIX/bin/automake" --version 2>&1 | head -n1 | cut -d" " -f3- )
echo $AUTOMAKE_VERSION
exit 1
if [[ $AUTOMAKE_VERSION == $PKG_AUTOMAKE ]]; then
  exit 0
fi

# Create build directory
mkdir -p "$TARGET_COMPILE/build/automake-$PKG_AUTOMAKE"

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
  # symlink
  ln -s "$TOOL_PREFIX/share/automake-$PKG_AUTOMAKE_INSTALL" automake
  ln -s "$TOOL_PREFIX/share/aclocal-$PKG_AUTOMAKE_INSTALL" aclocal
  # mark as installed
  touch "$TARGET_COMPILE/build/automake-$PKG_AUTOMAKE/automake.installed"
fi

# cleanup
rm -rf "$TARGET_COMPILE/build/automake-$PKG_AUTOMAKE"
