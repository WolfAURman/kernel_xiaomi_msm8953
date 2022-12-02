#!/bin/bash

# Kernel Build Script

#==================================#

# Cloning clang
CLANG="clang-trb"

    git clone --depth=1 https://gitlab.com/varunhardgamer/trb_clang ${CLANG}

# Cloning AnyKernel3
ANYKERNEL_VER="AnyKernel3"

    git clone --depth=1 https://github.com/Fuss-in-android/AnyKernel3 -b biogenesis ${ANYKERNEL_VER}

#==================================#

export PATH=""$(pwd)"${CLANG}/bin:$PATH"
export ARCH=arm64
export SUBARCH=arm64
export HEADER_ARCH=arm64

# Garbage removal

rm -rf out
mkdir out
rm -rf error.log
make O=out clean 
make mrproper

# Build

CLANG_DIR="$(pwd)"/${CLANG}

make O=out ARCH=arm64 daisy_defconfig

    make -j$(nproc --all) ARCH=arm64 SUBARCH=arm64 O=out \
        CC=${CLANG_DIR}/bin/clang \
        LD=${CLANG_DIR}/bin/ld.lld \
        AR=${CLANG_DIR}/bin/llvm-ar \
        AS=${CLANG_DIR}/bin/llvm-as \
        NM=${CLANG_DIR}/bin/llvm-nm \
        OBJCOPY=${CLANG_DIR}/bin/llvm-objcopy \
        OBJDUMP=${CLANG_DIR}/bin/llvm-objdump \
        STRIP=${CLANG_DIR}/bin/llvm-strip \
        CROSS_COMPILE=${CLANG_DIR}/bin/aarch64-linux-gnu- \
        CROSS_COMPILE_ARM32=${CLANG_DIR}/bin/arm-linux-gnueabi- 2>&1 | tee error.log

#==================================#

HASH=$(git rev-parse --short HEAD)
VER=$(make kernelversion)
BUILD_TIME=$(date +%d.%m.%y)

# Garbage removal
rm -rf "$(pwd)"/${ANYKERNEL_VER}/*.zip
rm -rf "$(pwd)"/${ANYKERNEL_VER}/*-dtb

cp "$(pwd)"/out/arch/arm64/boot/Image.gz-dtb "$(pwd)"/${ANYKERNEL_VER}
cd "$(pwd)"/${ANYKERNEL_VER}

NAME="[$BUILD_TIME]$VER-Biogenesis-Daisy-$HASH.zip"

# Packing in zip
zip -r9 "${NAME}" -- *

cd ..

echo "Build was successful! Take the zip by path: "$(pwd)"/${ANYKERNEL_VER}/${NAME}"

function init () {
    echo "
██████╗ ██╗ ██████╗  ██████╗ ███████╗███╗   ██╗███████╗███████╗██╗███████╗
██╔══██╗██║██╔═══██╗██╔════╝ ██╔════╝████╗  ██║██╔════╝██╔════╝██║██╔════╝
██████╔╝██║██║   ██║██║  ███╗█████╗  ██╔██╗ ██║█████╗  ███████╗██║███████╗
██╔══██╗██║██║   ██║██║   ██║██╔══╝  ██║╚██╗██║██╔══╝  ╚════██║██║╚════██║
██████╔╝██║╚██████╔╝╚██████╔╝███████╗██║ ╚████║███████╗███████║██║███████║
╚═════╝ ╚═╝ ╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═══╝╚══════╝╚══════╝╚═╝╚══════╝
                                                                          
            ██╗  ██╗███████╗██████╗ ███╗   ██╗███████╗██╗                 
            ██║ ██╔╝██╔════╝██╔══██╗████╗  ██║██╔════╝██║                 
            █████╔╝ █████╗  ██████╔╝██╔██╗ ██║█████╗  ██║                 
            ██╔═██╗ ██╔══╝  ██╔══██╗██║╚██╗██║██╔══╝  ██║                 
            ██║  ██╗███████╗██║  ██║██║ ╚████║███████╗███████╗            
            ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝"
}

init