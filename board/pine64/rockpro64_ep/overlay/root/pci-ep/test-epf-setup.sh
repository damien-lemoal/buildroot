#!/bin/sh

FUNC="pci_epf_test.0"
debug=0

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
echo "Loading pci-epf-test"
modprobe pci-epf-test || \
	exit_failed "Load pci-epf-test failed"

if [ "${debug}" == "1" ]; then
	# Enable pr_debug
	echo 8 > "/proc/sys/kernel/printk"
	echo -n 'module pci_epf_test +p;' > \
		"/sys/kernel/debug/dynamic_debug/control"
	echo -n 'file drivers/pci/controller/pcie-rockchip-ep.c +p;' > \
		"/sys/kernel/debug/dynamic_debug/control"
fi

# Setup the test endpoint function
echo "Creating NVME endpoint ${FUNC}"
mkdir "functions/pci_epf_test/${FUNC}" || \
	exit_failed "Create function 0 failed"

echo 0x104c > "functions/pci_epf_test/${FUNC}/vendorid" || \
	exit_failed "Set vendorid failed"
echo 0xb500 > "functions/pci_epf_test/${FUNC}/deviceid" || \
	exit_failed "Set deviceid failed"
echo 16 > "functions/pci_epf_test/${FUNC}/msi_interrupts" || \
	exit_failed "Set msi_interrupts failed"
#echo 8 > "functions/pci_epf_test/${FUNC}/msix_interrupts" || \
	#exit_failed "Set msix_interrupts failed"

echo "Attach test endpoint ${FUNC} to EP controller ${controller}"
ln -s "functions/pci_epf_test/${FUNC}" "${controller}/" || \
	exit_failed "Attach ${FUNC} to EP controller failed"

echo "Starting PCI EP controller"
echo 1 > "${controller}/start" || \
	exit_failed "Start PCI EP controller failed"
