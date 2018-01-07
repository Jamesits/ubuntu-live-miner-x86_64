#!/bin/bash
set -euv

# execute in chroot env
if [ "$(stat -c %d:%i /)" == "$(stat -c %d:%i /proc/1/root/.)" ]; then
    echo "This script is intended to be executed in chroot environment. Quitting."
    exit 1
fi

export DEBIAN_FRONTEND=noninteractive
export HOME=/root
export LC_ALL=C

# unmount previous mounted filesystem to prevent error
umount -lf /proc || true
umount -lf /sys || true
umount -lf /dev/pts || true

# mount things
mount none -t proc /proc || true
mount none -t sysfs /sys || true
mount none -t devpts /dev/pts || true

# update package list
apt-get update

# initialize dbus
apt-get install -y dbus
dbus-uuidgen > /var/lib/dbus/machine-id

# install livecd packages
apt-get -y upgrade
apt-get install -y ubuntu-standard casper lupin-casper discover laptop-detect os-prober plymouth-x11 openssh-server usbmount util-linux gdisk avahi-autoipd
apt-get install -y --install-recommends linux-generic-hwe-16.04 linux-tools-generic-hwe-16.04 linux-tools-common
apt-get -y -o DPkg::options::="--force-confdef" -o DPkg::options::="--force-confold" install grub-efi-amd64 grub-efi-amd64-signed
systemctl enable ssh

# config plymouth
cp /tmp/ubuntu-text.plymouth /usr/share/plymouth/themes/ubuntu-text/ubuntu-text.plymouth

# set up new user
newusers /tmp/userlist

# set up user privileges
while read u; do
	adduser ${u} sudo
	adduser ${u} video
	adduser ${u} audio
done < <(cut -d":" -f1 /tmp/userlist)

# install packages required by xmr-stak and used for debugging
apt-get install -y libhwloc5 hwloc libmicrohttpd10 htop hwloc lm-sensors i7z byobu w3m
systemctl enable xmr-stak.service

# rebuild initramfs
update-initramfs -u -k all

# cleanup
rm /var/lib/dbus/machine-id
apt-get autoremove -y --purge
apt-get clean -y
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/*
rm /etc/resolv.conf
ln -s /run/resolvconf/resolv.conf /etc/resolv.conf

# unmount filesystems
umount -lf /proc || true
umount -lf /sys || true
umount -lf /dev/pts || true
