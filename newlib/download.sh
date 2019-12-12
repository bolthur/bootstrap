#!/bin/bash
set -ex

# Create directory for source files
mkdir -p "$TARGET_COMPILE/source"
cd "$TARGET_COMPILE/source"

# automake
if [ ! -f automake-${PKG_AUTOMAKE}.tar.gz ]; then
  wget "https://ftp.gnu.org/gnu/automake/automake-${PKG_AUTOMAKE}.tar.gz"
  tar -xzf automake-${PKG_AUTOMAKE}.tar.gz
fi

# autoconf
if [ ! -f autoconf-${PKG_AUTOCONF}.tar.gz ]; then
  wget "https://ftp.gnu.org/gnu/autoconf/autoconf-${PKG_AUTOCONF}.tar.gz"
  tar -xzf autoconf-${PKG_AUTOCONF}.tar.gz
fi

# newlib
if [ ! -f newlib-${PKG_NEWLIB}.tar.gz ]; then
  wget "ftp://sourceware.org/pub/newlib/newlib-${PKG_NEWLIB}.tar.gz"
  tar -xzf newlib-${PKG_NEWLIB}.tar.gz
fi
