#!/bin/sh

is_ep=$(grep -c "pcie-ep" /boot/extlinux/extlinux.conf)
if [ ${is_ep} -eq 1 ]; then
	echo "Starting NVMe PCI target endpoint"
	cd /root/pci-ep
	./nvmet-pci-epf start
fi

exec /bin/login root
