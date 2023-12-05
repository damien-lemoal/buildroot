#!/bin/bash

# Rescan PCI bus
echo "Rescanning PCI bus..."

echo 1 > /sys/bus/pci/rescan

lspci
