#!/bin/bash
set -e

# Paths relative to GitHub Actions workspace
LLVM_PATH="$(pwd)/tc/clang/bin"
OUT_DIR="$(pwd)/out"
ANYKERNEL_DIR="$(pwd)/AnyKernel3/y2q"
DTBO_OUT="$OUT_DIR/arch/arm64/boot"
DTB_OUT="$OUT_DIR/arch/arm64/boot/dts/vendor/qcom"
IMAGE="$OUT_DIR/arch/arm64/boot/Image"

# Build environment
export PATH="$LLVM_PATH:$PATH"
export ARCH=arm64
export CC="${LLVM_PATH}/clang"
export CROSS_COMPILE="${LLVM_PATH}/aarch64-linux-gnu-"
export LLVM=1
export LLVM_IAS=1

# Clean old outputs
rm -f "$IMAGE" "$ANYKERNEL_DIR/kona.dtb" "$DTBO_OUT/dtbo.img" .version .local

# Config
make O="$OUT_DIR" vendor/kona-not_defconfig vendor/samsung/kona-sec-not.config vendor/samsung/y2q.config

# Build DTBO + DTB
make -j$(nproc) O="$OUT_DIR" DTC_EXT=$(pwd)/tools/dtc CONFIG_BUILD_ARM64_DT_OVERLAY=y dtbo.img
cp "$DTBO_OUT/dtbo.img" "$ANYKERNEL_DIR/dtbo.img"
cat "$DTB_OUT"/*.dtb > "$ANYKERNEL_DIR/kona.dtb"

# Build Kernel Image
make -j$(nproc) O="$OUT_DIR" Image
cp "$IMAGE" "$ANYKERNEL_DIR/Image"

# Package
gitsha=$(git rev-parse --short HEAD)
cd "$ANYKERNEL_DIR"
rm -f *.zip
zip -r9 "not-${gitsha}+r8q.zip" .
echo "✅ Build complete: not-${gitsha}+y2q.zip"
