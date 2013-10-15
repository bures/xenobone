#!/bin/sh

BUILD=build
PATCHES=patches
SKEL=skel

mkdir -p ${BUILD}
cd ${BUILD}

# ARM Cross Compiler: GCC
# =======================
if [ ! -e gcc-linaro-arm-linux-gnueabihf-4.8-2013.07-1_linux ]; then 
  wget -c https://launchpad.net/linaro-toolchain-binaries/trunk/2013.07/+download/gcc-linaro-arm-linux-gnueabihf-4.8-2013.07-1_linux.tar.xz
  tar xJf gcc-linaro-arm-linux-gnueabihf-4.8-2013.07-1_linux.tar.xz
fi

export CC=`pwd`/gcc-linaro-arm-linux-gnueabihf-4.8-2013.07-1_linux/bin/arm-linux-gnueabihf-


# Bootloader: U-Boot
# ==================
if [ ! -e u-boot ]; then 
  git clone git://git.denx.de/u-boot.git
  cd u-boot/
  git checkout v2013.07 -b tmp

  wget -c https://raw.github.com/eewiki/u-boot-patches/master/v2013.07/0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch
  patch -p1 < 0001-am335x_evm-uEnv.txt-bootz-n-fixes.patch

  make ARCH=arm CROSS_COMPILE=${CC} distclean
  make ARCH=arm CROSS_COMPILE=${CC} am335x_evm_config
  make ARCH=arm CROSS_COMPILE=${CC}
  cd ..
fi


# Download Xenomai
# ================
if [ ! -e xenomai-2.6.3 ]; then 
  wget http://download.gna.org/xenomai/stable/xenomai-2.6.3.tar.bz2
  tar -xvjf xenomai-2.6.3.tar.bz2 
fi


# Upgrade distro "device-tree-compiler" package
# =================================================
if [ ! -e dtc.sh ]; then 
  wget -c https://raw.github.com/RobertCNelson/tools/master/pkgs/dtc.sh
  chmod +x dtc.sh
  ./dtc.sh
fi


# Root File System
# ================
if [ ! -e debian-7.1-bare-armhf-2013-08-25 ]; then 
  wget -c https://rcn-ee.net/deb/barefs/wheezy/debian-7.1-bare-armhf-2013-08-25.tar.xz
  tar xJf debian-7.1-bare-armhf-2013-08-25.tar.xz
fi


# Linux Kernel build env
# ======================
if [ ! -e linux-dev ]; then 
  git clone git://github.com/RobertCNelson/linux-dev.git

  cd linux-dev/
  git checkout origin/am33x-v3.8 -b tmp
  cd ..
fi

# Linux Kernel build env+ Xenomai
# ======================

cd linux-dev

patch -p1 < ../../${PATCHES}/linux-dev.patch

./build_kernel.sh

cd ..
