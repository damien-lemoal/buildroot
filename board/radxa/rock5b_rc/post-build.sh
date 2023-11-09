#!/bin/sh

# Automatic login
if [ -e ${TARGET_DIR}/etc/inittab ]; then
    grep -qE '^console::respawn:-/bin/sh' ${TARGET_DIR}/etc/inittab || \
	sed -i 's,console::respawn:/sbin/getty -L  console 0 vt100 # GENERIC_SERIAL,console::respawn:-/bin/sh,g' ${TARGET_DIR}/etc/inittab
fi
