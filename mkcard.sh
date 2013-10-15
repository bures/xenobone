#!/bin/sh

BUILD=build
PATCHES=patches
SKEL=skel

DISK=/dev/sdb

umount /media/boot
umount /media/rootfs

export DISK=/dev/sdb
sudo dd if=/dev/zero of=${DISK} bs=1M count=16

sudo sfdisk --in-order --Linux --unit M ${DISK} <<-__EOF__
1,48,0xE,*
,,,-
__EOF__

sudo mkfs.vfat -F 16 ${DISK}1 -n boot
sudo mkfs.ext4 ${DISK}2 -L rootfs

sudo mkdir -p /media/boot/
sudo mkdir -p /media/rootfs/
 
sudo mount ${DISK}1 /media/boot/
sudo mount ${DISK}2 /media/rootfs/

sudo cp -v ${BUILD}/u-boot/MLO /media/boot/
sudo cp -v ${BUILD}/u-boot/u-boot.img /media/boot/

sudo cp -v ${SKEL}/uEnv.txt /media/boot/uEnv.txt

export kernel_version=3.8.13-bone28
sudo tar xfvp ${BUILD}/*-*-*-arm*-*/arm*-rootfs-*.tar -C /media/rootfs/

sudo cp -v $BUILD/linux-dev/deploy/${kernel_version}.zImage /media/boot/zImage

sudo mkdir -p /media/boot/dtbs/
sudo tar xfov ${BUILD}/linux-dev/deploy/${kernel_version}-dtbs.tar.gz -C /media/boot/dtbs/
sudo tar xfv ${BUILD}/linux-dev/deploy/${kernel_version}-firmware.tar.gz -C /media/rootfs/lib/firmware/

sudo tar xfv ${BUILD}/linux-dev/deploy/${kernel_version}-modules.tar.gz -C /media/rootfs/

sudo cp -v ${SKEL}/fstab /media/rootfs/etc/fstab
sudo cp -v ${SKEL}/interfaces /media/rootfs/etc/network/interfaces

sudo sh -c 'echo "T0:23:respawn:/sbin/getty -L ttyO0 115200 vt102" >> /media/rootfs/etc/inittab'

sync
sudo umount /media/boot
sudo umount /media/rootfs

sudo rmdir /media/boot/ /media/rootfs/

