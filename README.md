# bootstrap

Stuff necessary to build bolthur distribution

## building glibc

```bash
MAKE=make ../configure \
  --host=arm-unknown-bolthur-eabi \
  --with-pkgversion="GLIBC; bolthur bootstrap cross"

# due to a bug it's not possible to build static only glibc -.-'
# --disable-shared --enable-static
```
