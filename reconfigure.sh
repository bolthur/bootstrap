#!/bin/bash
set -ex

export DIR=$1

# tool prefix
export TOOL_PREFIX="/opt/bolthur/tool/newlib-arm-unknown-bolthur-eabi"
# Extend path for sub script calls
export PATH="$TOOL_PREFIX/bin:$PATH"

# switch to source directory
cd "$DIR/newlib"
echo "$DIR/newlib"
# reconfigure
autoconf
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi

# switch to source directory
cd "$DIR/newlib/libc/machine/arm"
# reconfigure
autoreconf
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi

# switch to source directory
cd "$DIR/newlib/libc/sys"
# reconfigure
autoreconf
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi

# switch to source directory
cd "$DIR/newlib/libc/sys/bolthur"
# reconfigure
autoreconf
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi

# switch to source directory
cd "$DIR/libgloss/arm"
# reconfigure
autoreconf
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi
