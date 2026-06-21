#!/bin/bash

set -e

KERNEL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
KERNEL_DEFCONFIG="gki_defconfig"
VENDOR_SYMVERS="$KERNEL_DIR/vendor-symvers/Module.symvers"

if [ -d "$KERNEL_DIR/../tools/google-clang" ]; then
    CLANG_DIR="$(cd "$KERNEL_DIR/../tools/google-clang" && pwd)"
elif [ -d "/home/deck/tools/google-clang" ]; then
    CLANG_DIR="/home/deck/tools/google-clang"
else
    CLANG_DIR="${CLANG_DIR_OVERRIDE:-}"
fi

if [ -z "$CLANG_DIR" ] || [ ! -f "$CLANG_DIR/bin/clang" ]; then
    echo "ERROR: clang not found. Set CLANG_DIR_OVERRIDE env var."
    echo "Usage: CLANG_DIR_OVERRIDE=/path/to/clang ./scripts/build.sh"
    exit 1
fi

CLANG_BINARY="$CLANG_DIR/bin/clang"
export PATH="$CLANG_DIR/bin:$PATH"
export KBUILD_COMPILER_STRING="$($CLANG_BINARY --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/ */ /g' -e 's/[[:space:]]*$//')"

cd "$KERNEL_DIR"

if [ -f "$VENDOR_SYMVERS" ]; then
    cp "$VENDOR_SYMVERS" "$KERNEL_DIR/Module.symvers"
    echo "Copied vendor Module.symvers"
fi

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
