#!/usr/bin/env bash
set -e

gzip -fk "${BINARIES_DIR}/Image"
cp board/radxa/rock5b_rc/rock5b_rc.its "${BINARIES_DIR}"
(cd "${BINARIES_DIR}" && mkimage -f rock5b_rc.its image.itb)
support/scripts/genimage.sh -c board/radxa/rock5b/genimage.cfg
