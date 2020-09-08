This is the Buildroot support for RISC-V Kendryte K210 SoC based boards.
Different variants of such boards are available from Sipeed (MAIX Dock,
Maixduino, Maix Go and Dan Dock) but the build procedure is similar for all of
them.

Steps to create a bootable image for a K210 board:

1) Configuration
  make kendryte_k210_defconfig
2) Build
  make
3) Boot the board
  The bootable image file loader.bin can be found in output/image. Flash this
  file onto the board ROM using the kflash.py utility:

  sudo python3 kflash.py -p /dev/ttyUSB0 -b 1500000 -t loader.bin

  The code for kflash.py is available on github at:

  https://github.com/sipeed/kflash.py

Note:

The current Linux support for the K210 is limited and devices such as GPIO or
SD card are not yet supported. As a result, this build procedure creates the
bootable image file by embedding the root filesystem image directly in the
kernel as a cpio initramfs image. Given the limited amount of memory of the
K210 (8MB of SDRAM), large root file system image will not work.
