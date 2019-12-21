#!/bin/bash
set -ex

# Package Verions
export PKG_AUTOMAKE="1.11.6"
export PKG_AUTOMAKE_INSTALL="1.11"
export PKG_AUTOCONF="2.64"
export PKG_NEWLIB="3.1.0"

# Bunch of prefixes
export CROSS_PREFIX="/opt/bolthur/$CROSS_SUFFIX"
export SYSROOT_BASE="/opt/bolthur/sysroot"
export TARGET_COMPILE="/opt/bolthur/tool"
export TOOL_PREFIX="/opt/bolthur/tool/$TOOL_PREFIX_SUFFIX"
# Extend path for sub script calls
export PATH="$TOOL_PREFIX/bin:$CROSS_PREFIX/bin:$PATH"
