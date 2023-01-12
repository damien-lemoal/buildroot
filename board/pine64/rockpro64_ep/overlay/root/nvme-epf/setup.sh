#!/bin/sh

target_dev="/dev/sda"
controller="controllers/fd000000.pcie_ep"

function exit_failed()
{
	echo "$1"
	exit 1
}

echo "Loading nvmet"

modprobe nvmet || \
	exit_failed "Load nvmet failed"

# Enable pr_debug for nvmet
echo 8 > /proc/sys/kernel/printk
echo -n 'module nvmet +p' > /sys/kernel/debug/dynamic_debug/control

echo "Creating NVME endpoint function 0"

cd /sys/kernel/config/pci_ep || \
	exit_failed "Missing PCI-EP"
modprobe pci-epf-nvme || \
	exit_failed "Load pci-epf-nvme failed"
mkdir functions/pci_epf_nvme/func0 || \
	exit_failed "Create function 0 failed"
echo $(nproc) > functions/pci_epf_nvme/func0/msi_interrupts || \
	exit_failed "Set msi_interrupts to $(nproc) failed"

echo "Set target device to ${target_dev}"

echo -n "${target_dev}" > functions/pci_epf_nvme/func0/nvmet/ns_device_path || \
	exit_failed "Set target device failed"

echo "Attach NVME endpoint function 0 to the PCI controller"

ln -s functions/pci_epf_nvme/func0 ${controller} || \
	exit_failed "Attach function 0 to controller failed"

echo "Starting the PCI controller"

#echo 1 > ${controller}/start || \
	#exit_failed "Start the PCI controller failed"
