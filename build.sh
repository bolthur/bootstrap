#!/bin/bash
set -x

# Build and install binutils if not installed
LD_VERSION=$( "$PREFIX/bin/$TARGET-ld" --version 2>&1 | head -n1 | cut -d" " -f8- )
if [[ $LD_VERSION != $PKG_BINUTILS ]] || [[ 1 == $REBUILD_BINUTILS ]]; then
  sh "$BASEDIR/binutils.sh" "static"
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

# check for installed gcc
GCC_VERSION=$( "$PREFIX/bin/$TARGET-gcc" --version 2>&1 | head -n1 | cut -d" " -f6- )
# default = install gcc
GCC_INSTALL=1;
if [[ $GCC_VERSION == $PKG_GCC ]]; then
  # check for libgcc.a and libstdc++ if gcc is installed
  LIBGCC=$( "$PREFIX/bin/$TARGET-gcc" --print-file-name=libgcc.a 2>&1 | head -n1 )
  #LIBCPP=$( "$PREFIX/bin/$TARGET-g++" --print-file-name=libstdc++.a 2>&1 | head -n1 )
  # reset GCC_INSTALL libgcc is existing
  # && -f "$LIBCPP" &&
  if [[ -f "$LIBGCC" ]]; then
    GCC_INSTALL=0
  fi
fi


# Build and install gcc stage 1 executable
if [[ 1 == $GCC_INSTALL ]] && [[ ! -f "$PREFIX/bin/$TARGET-gcc" ]]; then
  sh "$BASEDIR/gcc.sh" "stage1" "$GCC_MULTILIB_LIST" "static"
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

# check for newlib with static only libc
LIBC=$( "$PREFIX/bin/$TARGET-gcc" --print-file-name=libc.a 2>&1 | head -n1 )
# Build and install static newlib
if [[ ! -f "$LIBC" ]] || [[ 1 == $REBUILD_NEWLIB ]]; then
  sh "$BASEDIR/newlib.sh" "static"
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

# Build and install libgcc stage2 build
if [[ 1 == $GCC_INSTALL ]] || [[ 1 == $REBUILD_GCC ]]; then
  sh "$BASEDIR/gcc.sh" "stage2" "$GCC_MULTILIB_LIST" "static"
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

# Build and install gdb if not installed
GDB_VERSION=$( "$PREFIX/bin/$TARGET-gdb" --version 2>&1 | head -n1 | cut -d" " -f4- )
if [[ $GDB_VERSION != $PKG_GDB ]] || [[ 1 == $REBUILD_GDB ]]; then
  sh "$BASEDIR/gdb.sh"
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
fi

# Build and install ported libraries
sh "$BASEDIR/port.sh"
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi
