# Ubuntu Auto Miner LiveCD

Ubuntu LiveCD with xmr-stak pre-installed and pre-configured. Plug and mine!

## Build

Start from a Ubuntu 16.04:

```shell
# first execution
sudo make requirements
# otherwise clean build temp files first
sudo make clean

# then build iso
sudo make all
```

## Caveat

 * There are some cases build script will umount `/dev` or `/proc` on build server. **Prepare to hard reset build server at any time.**
 * CPU mining only. No support for graphics card.
 * EFI boot only. Legacy/CSM is not supported nor tested.
 * I recommend put the miners into a special LAN segment/VLAN and apply firewall rules (block all incoming).
 * The `xmr-stak` binary is built with donation level set to zero and using the following config:
 ```shell
 cmake .. -DCMAKE_BUILD_TYPE=Release -DMICROHTTPD_ENABLE=ON -DOpenSSL_ENABLE=ON -DCPU_ENABLE=ON -DHWLOC_ENABLE=ON -DOpenCL_ENABLE=OFF -DCUDA_ENABLE=OFF
 ```

## Usage

Burn the iso to USB disk using Rufus or other software. Plug in USB disk to destination PC and it should boot then start mining.

Login credential:

 * Username `iot`
 * Password `internetofshit`

You can log in using SSH.

To see miner speed report visit `http://your_miner_ip:9000`. The login credential is the same as above.

## Configuration

### Provide your own xmr-stak config

Put configuration (`{config,cpu}.txt`) in `xmr-stak` folder in USB disk root. It will be applied at boot.

If you don't provide your own config, it will mine using one core as a test.

### Load OS to RAM

You can load the root filesystem to RAM, so you can unplug the USB disk after system boot and it will continue to run. It takes ~600MB of RAM space.

Edit `boot/grub/grub.cfg`, insert `toram` after `splash` before `---` so it looks like:

```
linux	/casper/vmlinuz boot=casper root=/casper/filesystem.squashfs initrd=/casper/initrd.gz toram quiet splash ---
```

## Donation

Please donate if you like my work!

 * BTC: 1D96z5NEC64mRXDj4Mt1GjNLVb17aUA3HK
 * LTC: LKGpARdvAfJ6c583Wv28ivBCKCkan2ELbV
 * ETH: 0xfc5eF900f1399596fDB461391D8eEB3689729F3b
 * ETN: etnkGeJXNi3JyEL3FnKiA6gVcBXHevrx5GyyuQXAUivyYYaej3LYaxo1boFtd39PHLF9UDVWaWtzRVnR7ZAXmnEK1QcPYis4HD
