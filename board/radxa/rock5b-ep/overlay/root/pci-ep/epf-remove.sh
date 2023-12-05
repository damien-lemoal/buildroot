#!/bin/sh

source "$(dirname "$0")/epf-get-dev.sh"
dev=$(get_dev)

# Reset device
echo "Removing device ${dev}..."

echo 1 > /sys/bus/pci/devices/${dev}/remove
