#!/bin/bash
set -x

# Create directory for source files
mkdir -p "$TARGET_COMPILE/source"
cd "$TARGET_COMPILE/source"

# automake
if [[ ! -z "$PKG_AUTOMAKE" ]] && [[ ! -f automake-${PKG_AUTOMAKE}.tar.gz ]]; then
  wget "https://ftp.gnu.org/gnu/automake/automake-${PKG_AUTOMAKE}.tar.gz"
fi
if [[ ! -z "$PKG_AUTOMAKE" ]] && [[ ! -d "automake-${PKG_AUTOMAKE}" ]]; then
  tar -xzf automake-${PKG_AUTOMAKE}.tar.gz
fi
# autoconf
if [[ ! -z "$PKG_AUTOCONF" ]] && [[ ! -f autoconf-${PKG_AUTOCONF}.tar.gz ]]; then
  wget "https://ftp.gnu.org/gnu/autoconf/autoconf-${PKG_AUTOCONF}.tar.gz"
fi
if [[ ! -z "$PKG_AUTOCONF" ]] && [[ ! -d "autoconf-${PKG_AUTOCONF}" ]]; then
  tar -xzf autoconf-${PKG_AUTOCONF}.tar.gz
fi
# libtool
if [[ ! -z "$PKG_LIBTOOL" ]] && [[ ! -f libtool-${PKG_LIBTOOL}.tar.gz ]]; then
  wget "https://ftp.gnu.org/gnu/libtool/libtool-${PKG_LIBTOOL}.tar.gz"
fi
if [[ ! -z "$PKG_LIBTOOL" ]] && [[ ! -d "libtool-${PKG_LIBTOOL}" ]]; then
  tar -xzf libtool-${PKG_LIBTOOL}.tar.gz
fi
# autoconf archive
if [[ ! -z "$PKG_AUTOCONF_ARCHIVE" ]] && [[ ! -f autoconf-archive-${PKG_AUTOCONF_ARCHIVE}.tar.xz ]]; then
  wget "https://ftp.gnu.org/gnu/autoconf-archive/autoconf-archive-${PKG_AUTOCONF_ARCHIVE}.tar.xz"
fi
if [[ ! -z "$PKG_AUTOCONF_ARCHIVE" ]] && [[ ! -d "autoconf-archive-${PKG_AUTOCONF_ARCHIVE}" ]]; then
  tar -xf autoconf-archive-${PKG_AUTOCONF_ARCHIVE}.tar.xz
fi
# m4
if [[ ! -z "$PKG_M4" ]] && [[ ! -f m4-${PKG_M4}.tar.gz ]]; then
  wget "https://ftp.gnu.org/gnu/m4/m4-${PKG_M4}.tar.gz"
fi
if [[ ! -z "$PKG_M4" ]] && [[ ! -d "m4-${PKG_M4}" ]]; then
  tar -xzf m4-${PKG_M4}.tar.gz
fi
