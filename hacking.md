# hacking

## bash

```bash
CFLAGS="-D_POSIX_VERSION=1 -DNEED_EXTERN_PC -marm -march=armv7-a -mtune=cortex-a7 -mfpu=neon-vfpv4 -mfloat-abi=hard" ../configure --host=arm-unknown-bolthur-eabi --enable-static-link --without-bash-malloc --disable-nls
```

## glibc

https://preshing.com/20141119/how-to-build-a-gcc-cross-compiler/

```bash
# configure
MAKE=make ../configure --prefix=/opt/bolthur/foo --build=$MACHTYPE --host=arm-unknown-bolthur-eabi --target=arm-unknown-bolthur-eabi --with-headers=/opt/bolthur/foo/include --with-pkgversion="GLIBC; bolthur bootstrap cross" --enable-add-ons
# --enable-static-pie
# install bootstrap stuff
make install-bootstrap-headers=yes install-headers
make -j4 csu/subdir_lib
install csu/crt1.o csu/crti.o csu/crtn.o /opt/bolthur/foo/lib
aarch64-linux-gcc -nostdlib -nostartfiles -static -x c /dev/null -o /opt/bolthur/foo/libc.a
touch /opt/bolthur/foo/include/gnu/stubs.h
```
