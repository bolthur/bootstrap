#!/bin/bash
set -ex

# Package Verions
export PKG_BINUTILS="2.33.1"
export PKG_AUTOMAKE="1.15.1"
export PKG_AUTOMAKE_INSTALL="1.15"
export PKG_AUTOCONF="2.69"

export PREFIX="/opt/bolthur/$PREFIX_SUFFIX"
export TARGET_COMPILE="/opt/bolthur/tool"
export TOOL_PREFIX="/opt/bolthur/tool/$TOOL_PREFIX_SUFFIX"
# Extend path for sub script calls
export PATH="$TOOL_PREFIX/bin:$CROSS_PREFIX/bin:$PATH"

# Extend path for sub script calls
export PATH="$PREFIX/bin:$PATH"
