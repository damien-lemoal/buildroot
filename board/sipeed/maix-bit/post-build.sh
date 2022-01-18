#!/bin/sh

MKIMAGE=${HOST_DIR}/bin/mkimage

${MKIMAGE} -A riscv -O linux -T kernel -C none \
	-a 0x80000000 -e 0x80000000 \
	-n Linux -d ${BINARIES_DIR}/loader.bin ${BINARIES_DIR}/uImage

#find ${BUILD_DIR} -type f -name sipeed_maix_bit.dtb \
	#-exec cp "{}" ${BINARIES_DIR} \;

#install -m 0755 ${TARGET_DIR}/boot
#install -m 0644 -D ${BINARIES_DIR}/uImage ${TARGET_DIR}/boot/uImage
#install -m 0644 -D ${BINARIES_DIR}/sipeed_maix_bit.dtb ${TARGET_DIR}/boot/k210.dtb
