#!/bin/bash
set -ex

# target to build
export TARGET="aarch64-unknown-bolthur-eabi"
export GCC_MULTILIB_LIST="ilp32,lp64"