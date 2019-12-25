#!/bin/bash
set -ex

# Get cpu count
if [[ "$OSTYPE" == "darwin"* ]]; then
  CPU_COUNT=$(sysctl -n hw.physicalcpu)
else
  exit 0
fi

# Set sysroot variable
export SYSROOT=$1
# Check for set sysroot
if [ ! -z $SYSROOT ]; then
  # Change prefix to sysroot
  export PREFIX=$SYSROOT
  # Extend path for sub script calls
  export PATH="$PREFIX/bin:$PATH"
fi

# Create build directories
mkdir -p "$TARGET_COMPILE/build/gmp"
mkdir -p "$TARGET_COMPILE/build/mpfr"
mkdir -p "$TARGET_COMPILE/build/mpc"
mkdir -p "$TARGET_COMPILE/build/isl"

# configure gmp
if [ ! -f "$TARGET_COMPILE/build/gmp/crosscompiler.configured" ]; then
  cd "$TARGET_COMPILE/build/gmp"
  ../../source/gmp-$PKG_GMP/configure \
    --prefix="$PREFIX"
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as configured
  touch "$TARGET_COMPILE/build/gmp/crosscompiler.configured"
fi
# build gmp
if [ ! -f "$TARGET_COMPILE/build/gmp/crosscompiler.built" ]; then
  cd "$TARGET_COMPILE/build/gmp"

  make all -j${CPU_COUNT}
  if [ $? -ne 0 ]; then
    exit 1
  fi

  make check
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as built
  touch "$TARGET_COMPILE/build/gmp/crosscompiler.built"
fi
# install gmp
if [ ! -f "$TARGET_COMPILE/build/gmp/crosscompiler.installed" ]; then
  cd "$TARGET_COMPILE/build/gmp"

  make install
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as installed
  touch "$TARGET_COMPILE/build/gmp/crosscompiler.installed"
fi

# configure mpfr
if [ ! -f "$TARGET_COMPILE/build/mpfr/crosscompiler.configured" ]; then
  cd "$TARGET_COMPILE/build/mpfr"
  ../../source/mpfr-$PKG_MPFR/configure \
    --prefix="$PREFIX" \
    --with-gmp=$PREFIX
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as configured
  touch "$TARGET_COMPILE/build/mpfr/crosscompiler.configured"
fi
# build mpfr
if [ ! -f "$TARGET_COMPILE/build/mpfr/crosscompiler.built" ]; then
  cd "$TARGET_COMPILE/build/mpfr"

  make all -j${CPU_COUNT}
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as built
  touch "$TARGET_COMPILE/build/mpfr/crosscompiler.built"
fi
# install mpfr
if [ ! -f "$TARGET_COMPILE/build/mpfr/crosscompiler.installed" ]; then
  cd "$TARGET_COMPILE/build/mpfr"

  make install
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as installed
  touch "$TARGET_COMPILE/build/mpfr/crosscompiler.installed"
fi

# configure mpc
if [ ! -f "$TARGET_COMPILE/build/mpc/crosscompiler.configured" ]; then
  cd "$TARGET_COMPILE/build/mpc"
  ../../source/mpc-$PKG_MPC/configure \
    --prefix="$PREFIX" \
    --with-gmp=$PREFIX \
    --with-mpf=$PREFIX
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as configured
  touch "$TARGET_COMPILE/build/mpc/crosscompiler.configured"
fi
# build mpc
if [ ! -f "$TARGET_COMPILE/build/mpc/crosscompiler.built" ]; then
  cd "$TARGET_COMPILE/build/mpc"

  make all -j${CPU_COUNT}
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as built
  touch "$TARGET_COMPILE/build/mpc/crosscompiler.built"
fi
# install mpc
if [ ! -f "$TARGET_COMPILE/build/mpc/crosscompiler.installed" ]; then
  cd "$TARGET_COMPILE/build/mpc"

  make install
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as installed
  touch "$TARGET_COMPILE/build/mpc/crosscompiler.installed"
fi

# configure isl
if [ ! -f "$TARGET_COMPILE/build/isl/crosscompiler.configured" ]; then
  cd "$TARGET_COMPILE/build/isl"
  ../../source/isl-$PKG_ISL/configure \
    --prefix="$PREFIX" \
    --with-gmp-prefix=$PREFIX
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as configured
  touch "$TARGET_COMPILE/build/isl/crosscompiler.configured"
fi
# build isl
if [ ! -f "$TARGET_COMPILE/build/isl/crosscompiler.built" ]; then
  cd "$TARGET_COMPILE/build/isl"

  make all -j${CPU_COUNT}
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as built
  touch "$TARGET_COMPILE/build/isl/crosscompiler.built"
fi
# install isl
if [ ! -f "$TARGET_COMPILE/build/isl/crosscompiler.installed" ]; then
  cd "$TARGET_COMPILE/build/isl"

  make install
  if [ $? -ne 0 ]; then
    exit 1
  fi

  # mark as installed
  touch "$TARGET_COMPILE/build/isl/crosscompiler.installed"
fi
