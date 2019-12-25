#!/bin/bash
set -ex

# Target and sysroot
export CROSS_TARGET=$1
export BUILD_TARGET=$2
export SYSROOT=$3
export REBUILD=$4

# Get cpu count
if [[ "$OSTYPE" == "darwin"* ]]; then
  CPU_COUNT=$(sysctl -n hw.physicalcpu)
else
  CPU_COUNT=$(nproc)
fi

# On rebuild handle extend path
if [ ! -z $REBUILD ]; then
  # Extend path for sub script calls
  export CROSS_PREFIX="$SYSROOT"
  export PATH="$CROSS_PREFIX/bin:$PATH"
fi

## check for already installed
#AUTOMAKE_VERSION=$( "$TOOL_PREFIX/bin/automake" --version 2>&1 | head -n1 | cut -d" " -f3- )
#if [[ $AUTOMAKE_VERSION == $PKG_AUTOMAKE ]]; then
#  exit 0
#fi

# Create build directory
mkdir -p "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$BUILD_TARGET"

# apply necessary patches file by file
if [ ! -f "$TARGET_COMPILE/source/newlib-$PKG_NEWLIB/newlib.patched" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/newlib-$PKG_NEWLIB"
  # set patchdir
  NEWLIB_PATCHDIR="$PATCHDIR/newlib"
  # apply patch per patch
  for patch in $NEWLIB_PATCHDIR/*; do
    patch -d $TARGET_COMPILE/source/newlib-$PKG_NEWLIB -p0 < $patch
    # maybe better to use `git apply "$patch"` instead of patch
  done;
  # mark as patched
  touch "$TARGET_COMPILE/source/newlib-$PKG_NEWLIB/newlib.patched"
fi

# configure automake
if [ ! -f "$TARGET_COMPILE/source/newlib-$PKG_NEWLIB/newlib.generated" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/newlib-$PKG_NEWLIB/newlib/libc/sys"
  # reconfigure
  autoreconf
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # switch to source directory
  cd "$TARGET_COMPILE/source/newlib-$PKG_NEWLIB/newlib/libc/sys/bolthur"
  # reconfigure
  autoreconf
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # switch to source directory
  cd "$TARGET_COMPILE/source/newlib-$PKG_NEWLIB/libgloss/arm"
  # reconfigure
  autoreconf
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # switch to source directory
  cd "$TARGET_COMPILE/source/newlib-$PKG_NEWLIB/libgloss/aarch64"
  # reconfigure
  autoreconf
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as generated
  touch "$TARGET_COMPILE/source/newlib-$PKG_NEWLIB/newlib.generated"
fi

# hack cross compiler to hosted compiler via symlink
if [ -z $REBUILD ]; then
  if [ ! -f "$CROSS_PREFIX/bin/$BUILD_TARGET-ar" ]; then
    ln $CROSS_PREFIX/bin/$CROSS_TARGET-ar $CROSS_PREFIX/bin/$BUILD_TARGET-ar
  fi
  if [ ! -f "$CROSS_PREFIX/bin/$BUILD_TARGET-as" ]; then
    ln $CROSS_PREFIX/bin/$CROSS_TARGET-as $CROSS_PREFIX/bin/$BUILD_TARGET-as
  fi
  if [ ! -f "$CROSS_PREFIX/bin/$BUILD_TARGET-gcc" ]; then
    ln $CROSS_PREFIX/bin/$CROSS_TARGET-gcc $CROSS_PREFIX/bin/$BUILD_TARGET-gcc
  fi
  if [ ! -f "$CROSS_PREFIX/bin/$BUILD_TARGET-cc" ]; then
    ln $CROSS_PREFIX/bin/$CROSS_TARGET-gcc $CROSS_PREFIX/bin/$BUILD_TARGET-cc
  fi
  if [ ! -f "$CROSS_PREFIX/bin/$BUILD_TARGET-ranlib" ]; then
    ln $CROSS_PREFIX/bin/$CROSS_TARGET-ranlib $CROSS_PREFIX/bin/$BUILD_TARGET-ranlib
  fi
fi

# create cc if not created for rebuild
if [ ! -z $REBUILD ] && [ ! -f "$CROSS_PREFIX/bin/$BUILD_TARGET-cc" ]; then
  ln $CROSS_PREFIX/bin/$BUILD_TARGET-gcc $CROSS_PREFIX/bin/$BUILD_TARGET-cc
fi

# configure newlib
if [ ! -f "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$BUILD_TARGET/newlib.configured" ] || [ ! -z $REBUILD ]; then
  # switch to build directory
  cd "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$BUILD_TARGET"
  # configure
  ../../../source/newlib-$PKG_NEWLIB/configure --prefix=/usr --target=$BUILD_TARGET
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as configured
  touch "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$BUILD_TARGET/newlib.configured"
fi

# build newlib
if [ ! -f "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$BUILD_TARGET/newlib.built" ] || [ ! -z $REBUILD ]; then
  # switch to build directory
  cd "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$BUILD_TARGET"
  # build it
  make all -j${CPU_COUNT}
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as built
  touch "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$BUILD_TARGET/newlib.built"
fi

# install binutils for build target
if [ ! -f "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$BUILD_TARGET/newlib.installed" ] || [ ! -z $REBUILD ]; then
  # switch into build directory
  cd "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$BUILD_TARGET"
  # install
  make DESTDIR=${SYSROOT} install
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as installed
  touch "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$BUILD_TARGET/newlib.installed"

  # copy library headers
  if [[ "$OSTYPE" == "darwin"* ]]; then
    cp -a $SYSROOT/usr/$BUILD_TARGET/* $SYSROOT/usr/
  else
    cp -ar $SYSROOT/usr/$BUILD_TARGET/* $SYSROOT/usr/
  fi
  rm -rf $SYSROOT/usr/$BUILD_TARGET
fi

# remove cross compiler hack to hosted compiler
if [ -z $REBUILD ]; then
  if [ -f "$CROSS_PREFIX/bin/$BUILD_TARGET-ar" ]; then
    rm $CROSS_PREFIX/bin/$BUILD_TARGET-ar
  fi
  if [ -f "$CROSS_PREFIX/bin/$BUILD_TARGET-as" ]; then
    rm $CROSS_PREFIX/bin/$BUILD_TARGET-as
  fi
  if [ -f "$CROSS_PREFIX/bin/$BUILD_TARGET-gcc" ]; then
    rm $CROSS_PREFIX/bin/$BUILD_TARGET-gcc
  fi
  if [ -f "$CROSS_PREFIX/bin/$BUILD_TARGET-cc" ]; then
    rm $CROSS_PREFIX/bin/$BUILD_TARGET-cc
  fi
  if [ -f "$CROSS_PREFIX/bin/$BUILD_TARGET-ranlib" ]; then
    rm $CROSS_PREFIX/bin/$BUILD_TARGET-ranlib
  fi
fi
