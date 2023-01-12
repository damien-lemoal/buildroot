#!/bin/sh

sync
sync

FUNC="pci_epf_nvme.0"
target_dev="/dev/sda"
debug=0
mmio=0
bufferedio=0

function exit_failed()
{
	echo "$1"
	exit 1
}

function usage()
{
	echo "Usage: ${cmd} [Options]"
	echo "Options:"
	echo "  -h | --help: Print this help message"
	echo "  -d | --debug: Turn on kernel debug messages"
	echo "  -m | --mmio: Force mmio transfers (disable DMA)"
	echo "  -b | --buffered-io: Used buffered IOs on the target instead of direct IOs."
}

# Check options
while [ "${1#-}" != "$1" ]; do
	case "$1" in
	-h | --help)
		usage
		exit 0
		;;
	-d | --debug)
		debug=1
		shift
		;;
	-m | --mmio)
		mmio=1
		shift
		;;
	-b | --buffered-io)
		bufferedio=1
		shift
		;;
	-*)
		echo "unknow option $1"
		exit 1
		;;
	esac
done

# Check controller
cd /sys/kernel/config/pci_ep || \
	exit_failed "Missing PCI-EP"

controller="$(find controllers -name "*pcie*")"
if [ -z "${controller}" ]; then
	exit_failed "PCI EP Controller not found"
fi

# Load modules
echo "Loading nvmet"
modprobe nvmet || \
	exit_failed "Load nvmet failed"

echo "Loading pci-epf-nvme"
modprobe pci-epf-nvme || \
	exit_failed "Load pci-epf-nvme failed"

if [ "${debug}" == "1" ]; then
	# Enable pr_debug
	echo 8 > "/proc/sys/kernel/printk"
	echo -n 'module nvmet +p;' > \
		"/sys/kernel/debug/dynamic_debug/control"
	echo -n 'module pci_epf_nvme +p;' > \
		"/sys/kernel/debug/dynamic_debug/control"
	echo -n 'file drivers/pci/controller/pcie-rockchip-ep.c +p;' > \
		"/sys/kernel/debug/dynamic_debug/control"
fi

# Setup the NVMe endpoint function
echo "Creating NVME endpoint function ${FUNC}..."
mkdir "functions/pci_epf_nvme/${FUNC}" || \
	exit_failed "Create ${FUNK} failed"
sync

echo "    Set Vendor ID to Sandisk Corp (0x15b7)"
echo 0x15b7 > "functions/pci_epf_nvme/${FUNC}/vendorid" || \
	exit_failed "Set vendorid failed"

echo "    Set Device ID to dummy 0x5fff"
echo 0x5fff > "functions/pci_epf_nvme/${FUNC}/deviceid" || \
	exit_failed "Set deviceid failed"

echo "    Set MSI interrupts"
echo 32 > "functions/pci_epf_nvme/${FUNC}/msi_interrupts" || \
	exit_failed "Set msi_interrupts failed"

echo "    Set target backend device to ${target_dev}"
echo -n "${target_dev}" > "functions/pci_epf_nvme/${FUNC}/nvmet/ns_device_path" || \
	exit_failed "Set target backend device failed"

if [ "${mmio}" == "1" ]; then
	echo "    Disabling DMA"
	echo "0" > "functions/pci_epf_nvme/${FUNC}/nvmet/dma_enable" || \
		exit_failed "Disable DMA failed"
fi

if [ "${bufferedio}" == "1" ]; then
	echo "    Enabling target buffered IO"
	echo "1" > "functions/pci_epf_nvme/${FUNC}/nvmet/buffered_io" || \
		exit_failed "Enabling target buffered IO failed"
fi

sleep 0.2

# Start the NVMe endpoint function
echo "Attaching NVME endpoint function to PCI EP controller ${controller}..."
ln -s "functions/pci_epf_nvme/${FUNC}" "${controller}/" || \
	exit_failed "Attach function ${FUNC} to controller failed"

echo "Starting the PCI controller..."
echo 1 > "${controller}/start" || \
	exit_failed "Start the PCI EP controller failed"
