#!/bin/bash
set -x

# target to build
export TARGET="aarch64-unknown-bolthur-eabi"
export GCC_MULTILIB_LIST="ilp32,lp64"
