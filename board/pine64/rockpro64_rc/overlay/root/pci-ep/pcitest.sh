#!/bin/sh
# SPDX-License-Identifier: GPL-2.0

function exit_failed()
{
        echo "$1"
        exit 1
}

function run_pcitest()
{
        pcitest $@
        #sleep 0.1
}

# Load module
echo "## Loading pci_endpoint_test"
modprobe pci_endpoint_test || \
        exit_failed "Load pci_endpoint_test failed"

# Enable pr_debug
echo 8 > "/proc/sys/kernel/printk"
echo -n 'module pci_endpoint_test +p;' > "/sys/kernel/debug/dynamic_debug/control"
echo

echo "## BAR tests"
bar=0
while [ $bar -lt 5 ]; do
	run_pcitest -b $bar
	bar=`expr $bar + 1`
done
echo

echo "## Legacy interrupt tests"
run_pcitest -i 0
run_pcitest -l
echo

echo "## MSI interrupt tests"
run_pcitest -i 1
msi=1
while [ $msi -lt 17 ]; do
        run_pcitest -m $msi
        msi=`expr $msi + 1`
done
echo

echo "## MSIX interrupt tests"
run_pcitest -i 2
msix=1
while [ $msix -lt 17 ]; do
        run_pcitest -m $msix
        msix=`expr $msix + 1`
done
echo

echo "## Read Tests (DMA)"
run_pcitest -d -r -s 1
run_pcitest -d -r -s 1024
run_pcitest -d -r -s 1025
run_pcitest -d -r -s 4096
run_pcitest -d -r -s 131072
run_pcitest -d -r -s 1024000
run_pcitest -d -r -s 1024001
run_pcitest -d -r -s 1048576
echo

echo "## Write Tests (DMA)"
run_pcitest -d -w -s 1
run_pcitest -d -w -s 1024
run_pcitest -d -w -s 1025
run_pcitest -d -w -s 4096
run_pcitest -d -w -s 131072
run_pcitest -d -w -s 1024000
run_pcitest -d -w -s 1024001
run_pcitest -d -w -s 1048576
echo

echo "## Copy Tests (DMA)"
run_pcitest -d -c -s 1
run_pcitest -d -c -s 1024
run_pcitest -d -c -s 1025
run_pcitest -d -c -s 4096
run_pcitest -d -c -s 131072
run_pcitest -d -c -s 1024000
run_pcitest -d -c -s 1024001
run_pcitest -d -c -s 1048576
echo

echo "## Read Tests (No DMA)"
run_pcitest -r -s 1
run_pcitest -r -s 1024
run_pcitest -r -s 1025
run_pcitest -r -s 4096
run_pcitest -r -s 131072
run_pcitest -r -s 1024000
run_pcitest -r -s 1024001
echo

echo "## Write Tests (No DMA)"
run_pcitest -w -s 1
run_pcitest -w -s 1024
run_pcitest -w -s 1025
run_pcitest -w -s 4096
run_pcitest -w -s 131072
run_pcitest -w -s 1024000
run_pcitest -w -s 1024001
run_pcitest -w -s 1048576
echo

echo "## Copy Tests (No DMA)"
run_pcitest -c -s 1
run_pcitest -c -s 1024
run_pcitest -c -s 1025
run_pcitest -c -s 4096
run_pcitest -c -s 131072
run_pcitest -c -s 1024000
run_pcitest -c -s 1024001
run_pcitest -c -s 1048576
echo

