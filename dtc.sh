#!/bin/bash
set -x

# Create build directory
mkdir -p "$TARGET_COMPILE/build/dtc"

# install dtc
if [ ! -f "$TARGET_COMPILE/build/dtc/dtc.installed" ]; then
  cd "$TARGET_COMPILE/build/dtc"
  # make and install
  make install \
    MATCHCOMPILER=yes \
    SETUP_PREFIX="$PREFIX" \
    PREFIX="$PREFIX" \
    NO_PYTHON=1 \
    -C "../../source/dtc-$PKG_DTC"
  # handle error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as installed
  touch "$TARGET_COMPILE/build/dtc/dtc.installed"
fi
