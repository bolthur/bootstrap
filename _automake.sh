#!/bin/bash
set -ex

# Package Verions
export PKG_AUTOMAKE="1.16.1"
export PKG_AUTOMAKE_INSTALL="1.16"

export PREFIX="/opt/bolthur/$PREFIX_SUFFIX"
export TARGET_COMPILE="/opt/bolthur/tool"
export TOOL_PREFIX="/opt/bolthur/$PREFIX_SUFFIX"
# Extend path for sub script calls
export PATH="$TOOL_PREFIX/bin:$CROSS_PREFIX/bin:$PATH"

# Extend path for sub script calls
export PATH="$PREFIX/bin:$PATH"
