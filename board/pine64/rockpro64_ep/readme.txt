PINE64 ROCKPro64
================

Modified configuration for running PCIe endpoint mode.

General information on the RockPro64 board are available at:

https://www.pine64.org/rockpro64/

Configuration:
==============

Edit the files:

board/pine64/rockpro64_ep/overlay/etc/network/interfaces
board/pine64/rockpro64_ep/overlay/etc/resolv.conf

to set up networking as needed for your environment.

The kernel configuration file used is:

board/pine64/rockpro64_ep/linux.config

Kernel boot arguments can be modified by editiong the file:

board/pine64/rockpro64_ep/extlinux.conf

Build:
======
  $ make rockpro64_ep_defconfig
  $ make

Files created in output directory
=================================

output/images

├── bl31.elf
├── boot.vfat
├── extlinux
├── idbloader.img
├── Image
├── rk3399-rockpro64.dtb
├── rootfs.ext2
├── rootfs.ext4 -> rootfs.ext2
├── rootfs.tar
├── sdcard.img
├── u-boot.bin
└── u-boot.itb

Creating bootable SD card:
==========================

Simply invoke (as root)

# sudo dd if=output/images/sdcard.img of=/dev/sdX

Where X is your SD card device.

This operation does not write the GPT partition table header at the end of the
SD card. To avoid errors on boot, simply run as root:

# ( echo w ) | fdisk /dev/sdX

Booting:
========

RockPro64 has a 40-pin PI-2 GPIO Bus.

Connect a jumper between pin 23 and pin 25 for SD card boot.

Serial console:
---------------
The pin layout for serial console on PI-2 GPIO Bus is as follows:

pin 6:  gnd
pin 8:  tx
pin 10: rx

Initially connect pin 6 and pin 8(transmit). Apply power to RockPro64, once the
power is on then connect pin 10(receive).

Baudrate for this board is 1500000.

Login:
------

Enter 'root' as login user, the default password is 'buildroot'.
Local login and ssh login for root are both enabled by default.

The user 'buildroot' can also be used (password 'buildroot').
