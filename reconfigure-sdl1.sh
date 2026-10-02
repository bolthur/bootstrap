#!/bin/bash
set -x

export DIR=$1

# tool prefix
export TOOL_PREFIX="/opt/bolthur/build/tmp/sdl1-build"
# Extend path for sub script calls
export PATH="$TOOL_PREFIX/bin:$PATH"

# switch to source directory
cd "$DIR"
echo "$DIR"
sh ./autogen.sh
