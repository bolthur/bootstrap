#!/bin/bash
set -ex

# Build and install cppcheck if not installed
CPPCHECK_VERSION=$( "$PREFIX/bin/cppcheck" --version 2>&1 | head -n1 | cut -d" " -f2- )
if [[ $CPPCHECK_VERSION != $PKG_CPPCHECK ]]; then
  sh "$BASEDIR/cppcheck.sh"
fi

# Build and install binutils if not installed
LD_VERSION=$( "$PREFIX/bin/$TARGET-ld" --version 2>&1 | head -n1 | cut -d" " -f8- )
if [[ $LD_VERSION != $PKG_BINUTILS ]]; then
  sh "$BASEDIR/binutils.sh"
fi

# check for installed gcc
GCC_VERSION=$( "$PREFIX/bin/$TARGET-gcc" --version 2>&1 | head -n1 | cut -d" " -f6- )
# default = install gcc
GCC_INSTALL=1;
if [[ $GCC_VERSION == $PKG_GCC ]]; then
  # check for libgcc.a and libstdc++ if gcc is installed
  LIBGCC=$( "$PREFIX/bin/$TARGET-gcc" --print-file-name=libgcc.a 2>&1 | head -n1 )
  LIBCPP=$( "$PREFIX/bin/$TARGET-g++" --print-file-name=libstdc++.a 2>&1 | head -n1 )
  # reset GCC_INSTALL if both libraries are existing
  if [[ -f "$LIBGCC" && -f "$LIBCPP" ]]; then
    GCC_INSTALL=0
  fi
fi

if [[ 1 == $GCC_INSTALL ]]; then
  # Build and install gcc executable
  sh "$BASEDIR/gcc.sh" "stage1" "$GCC_MULTILIB_LIST"

  # Build and install newlib
  sh "$BASEDIR/newlib.sh"

  # Build and install libgcc
  sh "$BASEDIR/gcc.sh" "stage2" "$GCC_MULTILIB_LIST"
fi

# Build and install libgcc
sh "$BASEDIR/gcc.sh" "stage2" "$GCC_MULTILIB_LIST"

# Build and install gdb if not installed
GDB_VERSION=$( "$PREFIX/bin/$TARGET-gdb" --version 2>&1 | head -n1 | cut -d" " -f4- )
if [[ $GDB_VERSION != $PKG_GDB ]]; then
  sh "$BASEDIR/gdb.sh"
fi
