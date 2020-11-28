#!/bin/bash
set -ex

# Create directory for source files
mkdir -p "$TARGET_COMPILE/source/port"
cd "$TARGET_COMPILE/source/port"

# libtar
if [[ ! -f libtar-1.2.20.tar.gz ]]; then
  wget -O "libtar-1.2.20.tar.gz" "https://repo.or.cz/libtar.git/snapshot/0907a9034eaf2a57e8e4a9439f793f3f05d446cd.tar.gz"
fi
if [[ -d "libtar-1.2.20" ]]; then
  rm -rf "libtar-1.2.20"
fi
if [[ ! -d "libtar-1.2.20" ]]; then
  mkdir libtar-1.2.20
  tar -xzf libtar-1.2.20.tar.gz --strip 1 -C $TARGET_COMPILE/source/port/libtar-1.2.20
fi
# zlib
if [[ ! -f zlib-1.2.11.tar.gz ]]; then
  wget -O "zlib-1.2.11.tar.gz" "https://github.com/madler/zlib/archive/v1.2.11.tar.gz"
fi
if [[ -d "zlib-1.2.11" ]]; then
  rm -rf "zlib-1.2.11"
fi
if [[ ! -d "zlib-1.2.11" ]]; then
  tar -xzf zlib-1.2.11.tar.gz
fi

# # configure build and install zlib
# rm -rf $TARGET_COMPILE/build/port/zlib-$TARGET
# mkdir -p "$TARGET_COMPILE/build/port/zlib-$TARGET"
# # switch to build dir
# cd "$TARGET_COMPILE/build/port/zlib-$TARGET"
# # configure
# CHOST=$TARGET \
# ../../../source/port/zlib-1.2.11/configure \
#   --prefix=$SYSROOT/$TARGET \
#   --static
# exit 1
# # check for error
# if [ $? -ne 0 ]; then
#   exit 1
# fi
# # build and install library
# make install
# # check for error
# if [ $? -ne 0 ]; then
#   exit 1
# fi



# prepare autotools
cd "$TARGET_COMPILE/source/port/libtar-1.2.20"
autoreconf -iv
# configure build and install zlib
rm -rf $TARGET_COMPILE/build/port/libtar-$TARGET
mkdir -p "$TARGET_COMPILE/build/port/libtar-$TARGET"
# switch to build dir
cd "$TARGET_COMPILE/build/port/libtar-$TARGET"
# configure
../../../source/port/libtar-1.2.20/configure \
  --host=$TARGET \
  --prefix=$SYSROOT/$TARGET \
  --disable-shared
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi
exit 1
# build and install library
make install
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi
