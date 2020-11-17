#!/bin/bash
set -ex



# internal dependencies
export PKG_AUTOMAKE="1.15.1"
export PKG_AUTOMAKE_INSTALL="1.15"
export PKG_AUTOCONF="2.69"
# download
sh "$BASEDIR/download-internal.sh"
# tool prefix
export TOOL_PREFIX="/opt/bolthur/tool/gcc-$TARGET"
# Extend path for sub script calls
export PATH="$TOOL_PREFIX/bin:$PATH"
# automake and autoconf
sh "$BASEDIR/automake.sh"
sh "$BASEDIR/autoconf.sh"



# build type
export BUILD_STAGE=$1
export MULTILIB_LIST=$2

# add multilib parameter if set
export MULTILIB=""
if [ -n "$MULTILIB_LIST" ]; then
  export MULTILIB="--with-multilib-list=$MULTILIB_LIST"
fi

# Handle rebuild
if [[ -d "$TARGET_COMPILE/build/gcc.$BUILD_STAGE-$TARGET" ]] && [[ 1 == $REBUILD_GCC ]]; then
  rm -rf "$TARGET_COMPILE/build/gcc.$BUILD_STAGE-$TARGET"
fi
# Create build directory
mkdir -p "$TARGET_COMPILE/build/gcc.$BUILD_STAGE-$TARGET"

# switch to source directory
cd "$TARGET_COMPILE/source/gcc-$PKG_GCC"
# download prerequisites
./contrib/download_prerequisites
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi

# apply necessary patches file by file
if [ ! -f "$TARGET_COMPILE/source/gcc-$PKG_GCC/gcc.patched" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/gcc-$PKG_GCC"
  # set patch directories
  GCC_PATCHDIR="$PATCHDIR/gcc/$PKG_GCC"
  EXPERIMENTAL_GCC_PATCHDIR="$PATCHDIR/.experimental/gcc/$PKG_GCC"
  # handle experimental / work in progress
  if [[ 1 == $EXPERIMENTAL ]] && [[ -d "$EXPERIMENTAL_GCC_PATCHDIR" ]]; then
    GCC_PATCHDIR=$EXPERIMENTAL_GCC_PATCHDIR
  fi
  # apply patches
  if [[ -d "$GCC_PATCHDIR" ]]; then
    # apply patch per patch
    for patch in $GCC_PATCHDIR/*; do
      patch -d $TARGET_COMPILE/source/gcc-$PKG_GCC -p0 < $patch
    done;
    # mark as patched
    touch "$TARGET_COMPILE/source/gcc-$PKG_GCC/gcc.patched"
  fi
fi

# configure gcc
if [ ! -f "$TARGET_COMPILE/source/gcc-$PKG_GCC/gcc.generated" ]; then
  ## switch to source directory
  #cd "$TARGET_COMPILE/source/gcc-$PKG_GCC/libstdc++-v3"
  ## reconfigure
  #autoconf
  ## check for error
  #if [ $? -ne 0 ]; then
  #  exit 1
  #fi
  # switch to source directory
  cd "$TARGET_COMPILE/source/gcc-$PKG_GCC/gcc"
  # reconfigure
  autoconf
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as generated
  touch "$TARGET_COMPILE/source/gcc-$PKG_GCC/gcc.generated"
fi

# configure gcc for target
if [ ! -f "$TARGET_COMPILE/build/gcc.$BUILD_STAGE-$TARGET/gcc.configured" ]; then
  cd "$TARGET_COMPILE/build/gcc.$BUILD_STAGE-$TARGET"

  # cleanup build stage for stage 2 build
  BUILD_OPTION="--without-headers"
  if [[ "$BUILD_STAGE" == "stage2"* ]]; then
    # clear build option
    BUILD_OPTION=""
  fi

  ../../source/gcc-$PKG_GCC/configure \
    --target=$TARGET \
    --prefix="$PREFIX" \
    --disable-nls \
    --enable-languages=c,c++ \
    --disable-shared \
    --disable-werror \
    --with-newlib \
    --with-sysroot=$SYSROOT/$TARGET \
    --with-pkgversion="GCC; bolthur bootstrap cross" \
    $BUILD_OPTION \
    $MULTILIB

  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as configured
  touch "$TARGET_COMPILE/build/gcc.$BUILD_STAGE-$TARGET/gcc.configured"
fi
# build gcc for target
if [ ! -f "$TARGET_COMPILE/build/gcc.$BUILD_STAGE-$TARGET/gcc.built" ]; then
  cd "$TARGET_COMPILE/build/gcc.$BUILD_STAGE-$TARGET"

  make all-gcc -j${CPU_COUNT}
  if [ $? -ne 0 ]; then
    exit 1
  fi

  if [[ "$BUILD_STAGE" == "stage2"* ]]; then
    make all-target-libgcc -j${CPU_COUNT}
    if [ $? -ne 0 ]; then
      exit 1
    fi

    #make all-target-libstdc++-v3 -j${CPU_COUNT}
    #if [ $? -ne 0 ]; then
    #  exit 1
    #fi
  fi

  # mark as built
  touch "$TARGET_COMPILE/build/gcc.$BUILD_STAGE-$TARGET/gcc.built"
fi
# install gcc for target
if [ ! -f "$TARGET_COMPILE/build/gcc.$BUILD_STAGE-$TARGET/gcc.installed" ]; then
  cd "$TARGET_COMPILE/build/gcc.$BUILD_STAGE-$TARGET"

  make install-strip-gcc -j${CPU_COUNT}
  if [ $? -ne 0 ]; then
    exit 1
  fi

  if [[ "$BUILD_STAGE" == "stage2"* ]]; then
    make install-strip-target-libgcc -j${CPU_COUNT}
    if [ $? -ne 0 ]; then
      exit 1
    fi

    #make install-strip-target-libstdc++-v3 -j${CPU_COUNT}
    #if [ $? -ne 0 ]; then
    #  exit 1
    #fi
  fi

  # mark as installed
  touch "$TARGET_COMPILE/build/gcc.$BUILD_STAGE-$TARGET/gcc.installed"
fi
