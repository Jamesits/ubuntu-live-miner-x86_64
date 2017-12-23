VERSION=16.04.3
CODENAME=xenial
ARCH=amd64
VOLUME_ID="Miner_Live_AMD64"
DEBIAN_FRONTEND=noninteractive

.PHONY: clean clean-cache clean-all requirements restore-rootfs

clean:
	umount -lf rootfs/dev/pts || true
	umount -lf rootfs/proc || true
	umount -lf rootfs/sys || true
	umount -lf rootfs/dev || true
	rm -r rootfs || true
	rm -r image || true
	rm -r miner-$(VERSION)-livecd-$(ARCH).iso || true

clean-cache:
	rm rootfs_cache.tar.gz || true

clean-all: clean clean-cache

requirements:
	apt-get install dumpet xorriso squashfs-tools gddrescue debootstrap

ubuntu-$(VERSION)-server-$(ARCH).iso:
	wget https://mirrors4.tuna.tsinghua.edu.cn/ubuntu-releases/$(VERSION)/ubuntu-$(VERSION)-server-$(ARCH).iso

rootfs:
	rm -r build/rootfs || true
	mkdir -p build/rootfs
	debootstrap --arch=$(ARCH) $(CODENAME) build/rootfs http://cn.archive.ubuntu.com/ubuntu
	mv build/rootfs rootfs
	cp /etc/hosts rootfs/etc/hosts
	cp /etc/resolv.conf rootfs/etc/resolv.conf
	sed -e "s/xenial/$(CODENAME)/g" config/etc/apt/sources.list > rootfs/etc/apt/sources.list
	cp config/etc/modprobe.d/blacklist.conf rootfs/etc/modprobe.d/blacklist.conf
	mkdir -p rootfs/etc/systemd/system/networking.service.d
	cp config/etc/systemd/system/networking.service.d/timeout.conf rootfs/etc/systemd/system/networking.service.d/timeout.conf

rootfs_cache.tar.gz: rootfs
	tar -cvzf rootfs_cache.tar.gz rootfs

restore-rootfs: 
	rm -r rootfs || true
	tar -xvzf rootfs_cache.tar.gz

rootfs/etc/siggen-release: rootfs
	mount --bind /dev rootfs/dev
	# copy files before chroot
	cp config/usr/share/plymouth/themes/ubuntu-text/ubuntu-text.plymouth rootfs/tmp/ubuntu-text.plymouth
	cp script/write-image.sh rootfs/usr/local/bin/write-image
	cp script/update-squashfs.sh rootfs/usr/local/bin/update-squashfs
	cp script/prepare_rootfs.sh rootfs/tmp/prepare_rootfs.sh
	# prepare os
	chroot rootfs /tmp/prepare_rootfs.sh
	# copy files after chroot
	rm rootfs/tmp/prepare_rootfs.sh || true
	cp config/etc/usbmount/usbmount.conf rootfs/etc/usbmount/usbmount.conf
	cp config/etc/sysctl.d/panic.conf rootfs/etc/sysctl.d/panic.conf
	cp config/etc/sysctl.d/miner.conf rootfs/etc/sysctl.d/miner.conf
	cp config/etc/systemd/system.conf rootfs/etc/systemd/system.conf
	cp config/etc/issue rootfs/etc/issue
	cp config/etc/hostname rootfs/etc/hostname
	cp rootfs/etc/os-release rootfs/etc/siggen-release
	umount -lf rootfs/dev/pts || true
	umount -lf rootfs/sys || true
	umount -lf rootfs/proc || true
	umount -lf rootfs/dev || true

miner-$(VERSION)-livecd-$(ARCH).iso: rootfs rootfs/etc/siggen-release ubuntu-$(VERSION)-server-$(ARCH).iso
	# extract origin iso
	rm -r image || true
	xorriso -osirrox on -indev ubuntu-$(VERSION)-server-$(ARCH).iso -extract / image
	# remove installation files
	rm -r image/dists image/doc image/pics image/pool image/preseed image/install || true
	# populate boot files
	mkdir -p image/casper image/isolinux
	cp -v rootfs/boot/vmlinuz* image/casper/vmlinuz
	cp -v rootfs/boot/initrd.img* image/casper/initrd.gz
	cp -v config/boot/grub/grub.cfg image/boot/grub/grub.cfg
	dd if=ubuntu-$(VERSION)-server-$(ARCH).iso bs=512 count=1 of=image/isolinux/isohdpfx.bin
	# make squashfs
	rm image/casper/filesystem.squashfs || true
	mksquashfs rootfs/ image/casper/filesystem.squashfs
	# make iso
	sh -c "cd image; xorriso -as mkisofs -isohybrid-mbr isolinux/isohdpfx.bin -c isolinux/boot.cat -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot -isohybrid-gpt-basdat -volid $(VOLUME_ID) -o ../miner-$(VERSION)-livecd-$(ARCH).iso ."

all: miner-$(VERSION)-livecd-$(ARCH).iso
