#!/bin/bash
set -x

# Create build directory
mkdir -p "$TARGET_COMPILE/build/cppcheck"

# install cppcheck
if [ ! -f "$TARGET_COMPILE/build/cppcheck/cppcheck.installed" ]; then
  cd "$TARGET_COMPILE/build/cppcheck"
  # make and install
  make install \
    MATCHCOMPILER=yes \
    FILESDIR="$PREFIX/cppcheck" \
    HAVE_RULES=yes \
    CXXFLAGS="-O2 -DNDEBUG -Wall -Wno-sign-compare -Wno-unused-function" \
    -j${CPU_COUNT} \
    -C "../../source/cppcheck-$PKG_CPPCHECK"
  # handle error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as installed
  touch "$TARGET_COMPILE/build/cppcheck/cppcheck.installed"
fi
