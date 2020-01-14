#!/bin/bash
set -ex

. $(dirname "$0")/_base.sh

# build cross compiler
sh "$BASEDIR/baremetal-compiler.sh"

# build newlib
sh "$BASEDIR/baremetal-newlib.sh"

# os specific toolchain
sh "$BASEDIR/os-specific-compiler.sh"

# build newlib again
sh "$BASEDIR/os-specific-newlib.sh"

# remove sources and build related files
rm -rf /opt/bolthur/tool
