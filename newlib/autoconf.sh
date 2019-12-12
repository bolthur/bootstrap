#!/bin/bash
set -ex

# Get cpu count
if [[ "$OSTYPE" == "darwin"* ]]; then
  CPU_COUNT=$(sysctl -n hw.physicalcpu)
else
  CPU_COUNT=$(nproc)
fi

# check for already installed
AUTOCONF_VERSION=$( "$TOOL_PREFIX/bin/autoconf" --version 2>&1 | head -n1 | cut -d" " -f3- )
if [[ $AUTOCONF_VERSION == $PKG_AUTOCONF ]]; then
  exit 0
fi

# Create build directory
mkdir -p "$TARGET_COMPILE/build/autoconf-$PKG_AUTOCONF"

# configure automake
if [ ! -f "$TARGET_COMPILE/build/autoconf-$PKG_AUTOCONF/autoconf.configured" ]; then
  # switch to build directory
  cd "$TARGET_COMPILE/build/autoconf-$PKG_AUTOCONF"
  # configure
  ../../source/autoconf-$PKG_AUTOCONF/configure --prefix=$TOOL_PREFIX
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as configured
  touch "$TARGET_COMPILE/build/autoconf-$PKG_AUTOCONF/autoconf.configured"
fi

# build automake for target
if [ ! -f "$TARGET_COMPILE/build/autoconf-$PKG_AUTOCONF/autoconf.built" ]; then
  # switch to build directory
  cd "$TARGET_COMPILE/build/autoconf-$PKG_AUTOCONF"
  # build it
  make all -j${CPU_COUNT}
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as built
  touch "$TARGET_COMPILE/build/autoconf-$PKG_AUTOCONF/autoconf.built"
fi

# install binutils for target
if [ ! -f "$TARGET_COMPILE/build/autoconf-$PKG_AUTOCONF/autoconf.installed" ]; then
  # switch into build directory
  cd "$TARGET_COMPILE/build/autoconf-$PKG_AUTOCONF"
  # install
  make install
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as installed
  touch "$TARGET_COMPILE/build/autoconf-$PKG_AUTOCONF/autoconf.installed"
fi

# cleanup
rm -rf "$TARGET_COMPILE/build/autoconf-$PKG_AUTOCONF"
