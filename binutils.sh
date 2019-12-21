#!/bin/bash
set -ex

. $(dirname "$0")/_base.sh
. $(dirname "$0")/_binutils.sh

# Download everything
sh "$BASEDIR/binutils/download.sh"

# Build dependencies
sh "$BASEDIR/binutils/dependency.sh"

# automake
sh "$BASEDIR/_base/automake.sh"
sh "$BASEDIR/_base/autoconf.sh"

TARGET=$1
SYSROOT=$2
# Binutils
if [ ! -z $TARGET ]; then
  sh "$BASEDIR/binutils/binutils.sh" $TARGET $SYSROOT
fi