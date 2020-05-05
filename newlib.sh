#!/bin/bash
set -ex



# internal dependencies
export PKG_AUTOMAKE="1.11.6"
export PKG_AUTOMAKE_INSTALL="1.11"
export PKG_AUTOCONF="2.64"
# download
sh "$BASEDIR/download-internal.sh"
# tool prefix
export TOOL_PREFIX="/opt/bolthur/tool/newlib-$TARGET"
# Extend path for sub script calls
export PATH="$TOOL_PREFIX/bin:$PATH"
# automake and autoconf
sh "$BASEDIR/automake.sh"
sh "$BASEDIR/autoconf.sh"

# create cc if not created for rebuild
if [ ! -f "$PREFIX/bin/$TARGET-cc" ]; then
  ln $PREFIX/bin/$TARGET-gcc $PREFIX/bin/$TARGET-cc
fi

# Create build directory
mkdir -p "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$TARGET"

# apply necessary patches file by file
if [ ! -f "$TARGET_COMPILE/source/newlib-$PKG_NEWLIB/newlib.patched" ]; then
  # switch to source directory
  cd "$TARGET_COMPILE/source/newlib-$PKG_NEWLIB"
  # set patchdir
  NEWLIB_PATCHDIR="$PATCHDIR/newlib/$PKG_NEWLIB"
  if [ -d $NEWLIB_PATCHDIR ]; then
    # apply patch per patch
    for patch in $NEWLIB_PATCHDIR/*; do
      patch -d $TARGET_COMPILE/source/newlib-$PKG_NEWLIB -p0 < $patch
      # maybe better to use `git apply "$patch"` instead of patch
    done;
    # mark as patched
    touch "$TARGET_COMPILE/source/newlib-$PKG_NEWLIB/newlib.patched"
  fi
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

# configure newlib
if [ ! -f "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$TARGET/newlib.configured" ]; then
  # switch to build directory
  cd "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$TARGET"
  # configure
  ../../../source/newlib-$PKG_NEWLIB/configure --prefix= --target=$TARGET
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as configured
  touch "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$TARGET/newlib.configured"
fi

# build newlib
if [ ! -f "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$TARGET/newlib.built" ]; then
  # switch to build directory
  cd "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$TARGET"
  # build it
  make all -j${CPU_COUNT}
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as built
  touch "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$TARGET/newlib.built"
fi

# install binutils for build target
if [ ! -f "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$TARGET/newlib.installed" ]; then
  # switch into build directory
  cd "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$TARGET"
  # install
  make DESTDIR=${SYSROOT} install
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # move to usr subfolder folder
  rsync -av \
    $SYSROOT/$TARGET/* \
    $SYSROOT/$TARGET/usr \
    --exclude $SYSROOT/$TARGET/usr \
    --remove-source-files
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # Cleanup empty directories
  find $SYSROOT/$TARGET -type d -empty -delete
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # mark as installed
  touch "$TARGET_COMPILE/build/newlib-$PKG_NEWLIB/$TARGET/newlib.installed"
fi
