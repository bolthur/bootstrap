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



multilib=$($TARGET-gcc -print-multi-lib)
while read target
do
  # split target
  IFS=';' read -r -a split_target <<< "$target" # ; declare -p split_target
  # folder and option
  target_folder="${split_target[0]}"
  target_option="${split_target[1]}"
  # build options
  build_option=""
  # split options
  IFS='@' read -a option_list <<< "$target_option" # ; declare -p option_list
  # iterate options and prepare build options
  for option in "${option_list[@]}"
  do
    # skip empty
    if [[ "" == "$option" ]]; then
      continue
    fi
    # handle first
    if [[ "" == "$build_option" ]]; then
      build_option="-${option}"
    # handle normal append
    else
      build_option="${build_option} -${option}"
    fi
  done
  # replace dot with empty string
  if [[ "." == "$target_folder" ]]; then
    build_folder="zlib"
  else
    build_folder="zlib-$target_folder"
  fi
  if [[ -f "$SYSROOT/$TARGET/usr/lib/$target_folder/libz.a" ]]; then
    continue
  fi
  # create build dir
  rm -rf $TARGET_COMPILE/build/$build_folder
  mkdir -p "$TARGET_COMPILE/build/port/$build_folder"
  # switch to build dir
  cd "$TARGET_COMPILE/build/port/$build_folder"
  # configure
  CHOST=$TARGET \
  CFLAGS="${build_option}" \
  $TARGET_COMPILE/source/port/zlib-1.2.11/configure \
    --prefix=$SYSROOT/$TARGET \
    --includedir=$SYSROOT/$TARGET/usr/include \
    --libdir=$SYSROOT/$TARGET/usr/lib/$target_folder \
    --static
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
  # build and install library
  make install
  # check for error
  if [ $? -ne 0 ]; then
    exit 1
  fi
done <<< "$multilib"



# FIXME: ADD NECESSARY C LIBRARY FUNCTIONS AND UNCOMMENT AGAIN
## multilib=$($TARGET-gcc -print-multi-lib)
## while read target
## do
##   # split target
##   IFS=';' read -r -a split_target <<< "$target" # ; declare -p split_target
##   # folder and option
##   target_folder="${split_target[0]}"
##   target_option="${split_target[1]}"
##   # build options
##   build_option=""
##   # split options
##   IFS='@' read -a option_list <<< "$target_option" # ; declare -p option_list
##   # iterate options and prepare build options
##   for option in "${option_list[@]}"
##   do
##     # skip empty
##     if [[ "" == "$option" ]]; then
##       continue
##     fi
##     # handle first
##     if [[ "" == "$build_option" ]]; then
##       build_option="-${option}"
##     # handle normal append
##     else
##       build_option="${build_option} -${option}"
##     fi
##   done
##   # replace dot with empty string
##   if [[ "." == "$target_folder" ]]; then
##     build_folder="libtar"
##   else
##     build_folder="libtar-$target_folder"
##   fi
##   if [[ -f "$SYSROOT/$TARGET/usr/lib/$target_folder/libtar.a" ]]; then
##     continue
##   fi
##   # prepare autotools
##   cd "$TARGET_COMPILE/source/port/libtar-1.2.20"
##   autoreconf -iv
##   # configure build and install zlib
##   rm -rf $TARGET_COMPILE/build/port/$build_folder
##   mkdir -p "$TARGET_COMPILE/build/port/$build_folder"
##   # switch to build dir
##   cd "$TARGET_COMPILE/build/port/$build_folder"
##   # configure
##   $TARGET_COMPILE/source/port/libtar-1.2.20/configure \
##     --host=$TARGET \
##     --prefix=$SYSROOT/$TARGET \
##     --includedir=$SYSROOT/$TARGET/usr/include \
##     --libdir=$SYSROOT/$TARGET/usr/lib/$target_folder \
##     --disable-shared
##   # check for error
##   if [ $? -ne 0 ]; then
##     exit 1
##   fi
##   # build and install library
##   make install
##   # check for error
##   if [ $? -ne 0 ]; then
##     exit 1
##   fi
## done <<< "$multilib"
