This is the Buildroot support for Canaan RISC-V Kendryte K210 SoC based boards.
Different variants of such boards are available from Sipeed (MAIX Dock,
Maixduino, Maix Go and Dan Dock) and from Canaan. A different configuration file
is provided for each board supported.

+------------------------+-----------------------------+
| Board vendor and model | config name                 |
+------------------------+-----------------------------+
| Canaan K210 (generic)  | canaan_k210_defconfig       |
+------------------------+-----------------------------+
| Canaan KD233           | canaan_kd233_defconfig      |
+------------------------+-----------------------------+
| Sipedd MAIX bit        | sipeed_maix_bit_defconfig   |
+------------------------+-----------------------------+
| Sipedd MAIX Go         | sipeed_maix_go_defconfig    |
+------------------------+-----------------------------+
| Sipedd MAIX dock       | sipeed_maix_dock_defconfig  |
+------------------------+-----------------------------+

The build procedure is similar for all boards.

Steps to create a bootable image for a K210 board:

1) Configuration
  make <config name>
2) Build
  make
3) Boot the board
  The bootable image file loader.bin can be found in output/image. Flash this
  file onto the board ROM using the kflash.py utility:

  sudo python3 kflash.py -p /dev/ttyUSB0 -b 1500000 -t loader.bin

  The code for kflash.py is available on github at:

  https://github.com/sipeed/kflash.py
