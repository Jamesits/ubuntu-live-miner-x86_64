# Ubuntu Auto Miner LiveCD

Ubuntu LiveCD with xmr-stak pre-installed and pre-configured. Plug and mine!

 * Super light: ~400M rootfs, ~270M memory, <10s boot time
 * Super easy: plug, boot, mine
 * Super power: latest xmr-stak optimized for newer Intel CPU with large L3/L4 caches
 
 [Download](https://github.com/Jamesits/ubuntu-live-miner-x86_64/releases/latest)

## Caveats

 * CPU mining only. No support for graphics card.
 * EFI boot only. Legacy/CSM is not supported nor tested.
 * I recommend put the miners into a special LAN segment/VLAN and apply firewall rules (block all incoming requests).
 * The `xmr-stak` is built on my Intel i7-4770HQ with `--march=native`. It may cause issues on other platforms.

## Usage

Burn the iso to USB disk using [Rufus](https://rufus.akeo.ie/) or other software. Plug in USB disk to destination PC and it should boot then start mining.

Login credential:

 * Username `iot`
 * Password `internetofshit`

You can log in using SSH.

To see miner speed report visit `http://your_miner_ip:9000`. The login credential is the same as above.

## Configuration

### Networking

It accepts DHCPv4 and IPv6 SLAAC.

If you need static IP address, add `ip=IFACE,ADDRESS,NETMASK,GATEWAY[:IFACE,ADDRESS,NETMASK,GATEWAY]*` to `boot/grub/grub.cfg` kernel comandline.

### Provide your own xmr-stak config

Put configuration (`{config,cpu}.txt`) in `xmr-stak` folder in USB disk root. It will be applied at boot. If you want to provide your own `xmr-stak` executable you can put that in too.

If you don't provide your own config, it will mine Monero using one CPU core as a test load.

### Load OS to RAM (Optional)

You can load the root filesystem to RAM, so you can unplug the USB disk after system boot and it will continue to run. It requires ~460MB of RAM space and the boot time will be slightly longer.

Edit `boot/grub/grub.cfg`, add `toram` to kernel commandline.
```

## Build

There are some cases build script will umount `/dev` or `/proc` on build server. **Prepare to hard reset build server at any time.**

Start from a Ubuntu 16.04 64-bit:

```shell
# first execution
sudo make requirements
# otherwise clean build temp files first
sudo make clean

# then build iso
sudo make all
```

If you got some download error/hash sum mismatch error in the build process, run `sudo make all` again.

The provided `xmr-stak` binary is built with donation level set to zero and using the following config:
 ```shell
 cmake .. -DCMAKE_BUILD_TYPE=Release -DMICROHTTPD_ENABLE=ON -DOpenSSL_ENABLE=ON -DCPU_ENABLE=ON -DHWLOC_ENABLE=ON -DOpenCL_ENABLE=OFF -DCUDA_ENABLE=OFF
 ```

## Donation

Please donate if you like my work!

 * BTC: 1D96z5NEC64mRXDj4Mt1GjNLVb17aUA3HK
 * LTC: LKGpARdvAfJ6c583Wv28ivBCKCkan2ELbV
 * ETH: 0xfc5eF900f1399596fDB461391D8eEB3689729F3b
 * ETN: etnkGeJXNi3JyEL3FnKiA6gVcBXHevrx5GyyuQXAUivyYYaej3LYaxo1boFtd39PHLF9UDVWaWtzRVnR7ZAXmnEK1QcPYis4HD
