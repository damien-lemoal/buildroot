#!/bin/sh

source "$(dirname "$0")/epf-get-dev.sh"
dev=$(get_dev)

echo "unbinding NVMe driver from ${dev}..."
echo "$dev" > /sys/bus/pci/drivers/nvme/unbind
sleep 0.1
echo "re-binding NVMe driver from ${dev}..."
echo "$dev" > /sys/bus/pci/drivers/nvme/bind
