#!/bin/bash
set -euv

BOOT=/cdrom
SOURCE=/media/usb1

mount -o rw,remount /cdrom

# copy grub config
cp ${SOURCE}/boot/grub/grub.cfg ${BOOT}/boot/grub/grub.cfg

# copy system image
cp -v ${SOURCE}/casper/* ${BOOT}/casper

# flush buffer
sync
sync
