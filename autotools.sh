#!/bin/bash
set -x



# internal dependencies
export PKG_AUTOMAKE="1.16.3"
export PKG_AUTOMAKE_INSTALL="1.16"
export PKG_AUTOCONF="2.71"
export PKG_LIBTOOL="2.4.6"
export PKG_M4="1.4.18"
# download
sh "$BASEDIR/download-internal.sh"
# tool prefix
export TOOL_PREFIX="/opt/bolthur/cross"

# automake and autoconf
sh "$BASEDIR/autotools/m4.sh"
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi

sh "$BASEDIR/autotools/autoconf.sh"
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi

sh "$BASEDIR/autotools/automake.sh"
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi

sh "$BASEDIR/autotools/libtool.sh"
# check for error
if [ $? -ne 0 ]; then
  exit 1
fi
