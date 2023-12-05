#!/bin/bash

function get_dev()
{
	local d

	d="$(lspci | grep 'Western Digital Device beef' | cut -d ' ' -f 1)"
	if [ -z "${d}" ]; then
		echo "device not found"
		exit 1
	fi

	echo "0000:${d}"
}

dev="$(get_dev)"

# Reset device
echo "Removing device ${dev}..."

echo 1 > /sys/bus/pci/devices/${dev}/remove
