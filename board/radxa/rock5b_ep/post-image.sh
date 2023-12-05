#!/usr/bin/env bash
set -e

gzip -fk "${BINARIES_DIR}/Image"
cp board/radxa/rock5b_ep/rock5b_ep.its "${BINARIES_DIR}"
(cd "${BINARIES_DIR}" && mkimage -f rock5b_ep.its image.itb)
support/scripts/genimage.sh -c board/radxa/rock5b_ep/genimage.cfg
