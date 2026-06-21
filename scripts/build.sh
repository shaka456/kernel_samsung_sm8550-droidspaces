#!/bin/bash

set -e

KERNEL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
KERNEL_DEFCONFIG="gki_defconfig"
CLANG_VERSION="clang-r547379"
VENDOR_SYMVERS="$KERNEL_DIR/vendor-symvers/Module.symvers"

CLANG_DIR="${CLANG_DIR_OVERRIDE:-}"
if [ -z "$CLANG_DIR" ] || [ ! -f "$CLANG_DIR/bin/clang" ]; then
    for dir in "$KERNEL_DIR/../tools/google-clang" "/home/deck/tools/google-clang" "$KERNEL_DIR/tools/google-clang"; do
        if [ -d "$dir" ]; then
            CLANG_DIR="$dir"
            break
        fi
    done
fi

if [ -z "$CLANG_DIR" ] || [ ! -f "$CLANG_DIR/bin/clang" ]; then
    CLANG_DIR="$KERNEL_DIR/tools/google-clang"
    echo "Clang not found locally. Downloading $CLANG_VERSION from GitHub Releases..."
    mkdir -p "$KERNEL_DIR/tools"
    CLANG_URL="https://github.com/shaka456/kernel_samsung_sm8550-droidspaces/releases/download/$CLANG_VERSION/$CLANG_VERSION.tar.gz"
    if command -v wget &>/dev/null; then
        wget -q --show-progress "$CLANG_URL" -O "/tmp/$CLANG_VERSION.tar.gz"
    elif command -v curl &>/dev/null; then
        curl -L "$CLANG_URL" -o "/tmp/$CLANG_VERSION.tar.gz"
    else
        echo "ERROR: wget or curl required to download clang."
        exit 1
    fi
    tar -xzf "/tmp/$CLANG_VERSION.tar.gz" -C "$KERNEL_DIR/tools"
    rm "/tmp/$CLANG_VERSION.tar.gz"
    echo "Clang downloaded and extracted to $CLANG_DIR"
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
