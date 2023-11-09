#!/bin/bash

dev="0000:01:00.0"

# Reset device
echo "Removing device ${dev}..."

echo 1 > /sys/bus/pci/devices/${dev}/remove
