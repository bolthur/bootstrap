#!/bin/bash
set -ex

# target to build
export TARGET="arm-unknown-bolthur-eabi"
export GCC_MULTILIB_LIST="aprofile,rmprofile"
