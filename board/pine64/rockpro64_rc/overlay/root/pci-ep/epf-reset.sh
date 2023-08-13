#!/bin/sh

function get_dev()
{
	local d

	d="$(lspci | grep 'Sandisk Corp Device 5fff' | cut -d ' ' -f 1)"
	if [ -z "${d}" ]; then
		echo "device not found"
		exit 1
	fi

	echo "0000:${d}"
}

dev="$(get_dev)"

if [ -e "/sys/bus/pci/drivers/nvme/${dev}" ]; then
	echo "Unbind ${dev}..."
	echo -n "${dev}" > /sys/bus/pci/drivers/nvme/unbind
	sleep 0.5

	# Reset device
	#echo "Resetting ${dev}..."
	#echo bus > /sys/bus/pci/devices/${dev}/reset_method
	#echo 1 > /sys/bus/pci/devices/${dev}/reset
	#sleep 0.5

	echo "Remove ${dev} and rescan..."
	echo 1 > /sys/bus/pci/devices/${dev}/remove
	sleep 0.5
fi

echo "PCI rescan..."
echo 1 > "/sys/bus/pci/rescan"

#dev="$(get_dev)"
#echo "Bind ${dev}..."
#echo -n "${dev}" > /sys/bus/pci/drivers/nvme/bind

