#!/bin/sh

BOARD_DIR="$(dirname "$0")"

if [ "${RCHOST}" == "y" ]; then
	echo "RC post build"
	install -m 0644 -D "$BOARD_DIR"/extlinux-rc.conf "$TARGET_DIR"/boot/extlinux/extlinux.conf
elif [ "${EPONELANE}" == "y" ]; then
	echo "EP (one lane) post build"
	install -m 0644 -D "$BOARD_DIR"/extlinux-ep-onelane.conf "$TARGET_DIR"/boot/extlinux/extlinux.conf
else
	echo "EP post build"
	install -m 0644 -D "$BOARD_DIR"/extlinux-ep.conf "$TARGET_DIR"/boot/extlinux/extlinux.conf
fi

# Automatic login
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^console::respawn:-/bin/sh' ${TARGET_DIR}/etc/inittab || \
	sed -i 's,console::respawn:/sbin/getty -L  console 0 vt100 # GENERIC_SERIAL,console::respawn:-/bin/sh,g' ${TARGET_DIR}/etc/inittab
fi
