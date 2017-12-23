#!/bin/bash
set -euv

DEVICE=/dev/mmcblk0

# create GPT table
sgdisk -og ${DEVICE}

# create EFI partition
ENDSECTOR=`sgdisk -E ${DEVICE}`
sgdisk -n 1:2048:${ENDSECTOR} -c 1:"SigGen Live!" -t 1:ef00 ${DEVICE}

# print partition table
sgdisk -p ${DEVICE}

# format disk
mkfs -t vfat ${DEVICE}p1

# install grub
mkdir -p /media/efi
mount ${DEVICE}p1 /media/efi
grub-install --force --recheck --root-directory=/media/efi --efi-directory=/media/efi --uefi-secure-boot ${DEVICE}

# copy grub config
cp /cdrom/boot/grub/grub.cfg /media/efi/boot/grub/grub.cfg

# copy system image
mkdir -p /media/efi/casper
cp -v /cdrom/casper/* /media/efi/casper

# flush buffer
sync
sync
