#!/bin/bash
set -ex

export PREFIX_SUFFIX="os"
export TOOL_PREFIX_SUFFIX="automake"

. $(dirname "$0")/_base.sh
. $(dirname "$0")/_automake.sh

# Download everything
sh "$BASEDIR/automake/download.sh"

# Build necessary newlib tools
sh "$BASEDIR/_base/automake.sh"
