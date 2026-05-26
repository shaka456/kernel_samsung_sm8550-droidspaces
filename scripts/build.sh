#!/bin/bash

set -e

KERNEL_DIR="/home/deck/kernel/kernel5.15.185/kernel_samsung_sm8550-common-5.15.185"
KERNEL_DEFCONFIG="gki_defconfig"
CLANG_DIR="/home/deck/tools/google-clang"
CLANG_BINARY="$CLANG_DIR/bin/clang"

export PATH="$CLANG_DIR/bin:$PATH"
export KBUILD_COMPILER_STRING="$($CLANG_BINARY --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')"

cd "$KERNEL_DIR"

echo "Building kernel with Clang: $KBUILD_COMPILER_STRING"

make -j$(nproc --all) CC=clang \
                      LD=ld.lld \
                      LLVM=1 \
                      LLVM_IAS=1 \
                      ARCH=arm64 \
                      $KERNEL_DEFCONFIG

make -j$(nproc --all) CC=clang \
                      LD=ld.lld \
                      LLVM=1 \
                      LLVM_IAS=1 \
                      ARCH=arm64