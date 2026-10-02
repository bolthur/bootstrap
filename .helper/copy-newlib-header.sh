#!/bin/bash
set -x
# save parameters
export SYSROOT=$1
export NEWLIB=$2
# create directory
mkdir -p $SYSROOT/usr/include
# copy include files
if [[ "$OSTYPE" == "darwin"* ]]; then
  cp -R $NEWLIB/newlib/libc/include/ $SYSROOT/usr/include
  cp -R $NEWLIB/newlib/libc/sys/bolthur/sys/ $SYSROOT/usr/include/sys
else
  cp -RT $NEWLIB/newlib/libc/include $SYSROOT/usr/include
  cp -RT $NEWLIB/newlib/libc/sys/bolthur/sys $SYSROOT/usr/include/sys
fi
