#!/bin/sh

if [ $# == 1 ]; then
	dev="$1"
else
	dev="/dev/disk/by-id/$(ls /dev/disk/by-id/ | \
		grep nvme-Linux-pci-epf | tail -1)"
fi
dev="$(realpath ${dev})"

if [ ! -b "${dev}" ]; then
        echo "${dev} is not a block device file"
        exit 1
fi

runtime=20

function run_fio()
{
	local title="$1"
	local rw="$2"
	local bs="$3"
	local qd=$4
	local nrjobs="$5"

	name="${rw}-${bs}-${qd}x${nrjobs}"

	fiocmd="fio --name=\"${name}\" --filename=${dev}"
	fiocmd="${fiocmd} --thread"
	fiocmd="${fiocmd} --rw=${rw} --direct=1"
	if [ ${qd} -eq 1 ]; then
		fiocmd="${fiocmd} --ioengine=psync"
	else
		fiocmd="${fiocmd} --ioengine=io_uring --iodepth=${qd}"
	fi

	range=$(echo ${bs} | grep -c "-")
	if [ ${range} == 0 ]; then
		fiocmd="${fiocmd} --bs=${bs}"
	else
		fiocmd="${fiocmd} --bsrange=${bs}"
	fi

	fiocmd="${fiocmd} --numjobs=${nrjobs}"
	fiocmd="${fiocmd} --cpus_allowed=0-$(( $(nproc) - 1 ))"
	fiocmd="${fiocmd} --cpus_allowed_policy=split"
	fiocmd="${fiocmd} --group_reporting=1"
	fiocmd="${fiocmd} --norandommap=1"
	fiocmd="${fiocmd} --runtime=${runtime}"

	log="${name}.log"
	echo "  ${fiocmd}" > "${log}" 2>&1

	echo -n "  ${title}: "

	eval "${fiocmd}" >> "${log}" 2>&1

	grep IOPS "${log}" | cut -f-2 -d'(' | sed -e 's/^//' | cut -f2- -d':'

	sync
}

# Execute the runs
echo "Running on ${dev}..."

run_fio "Rnd read,    4KB,  QD=1, 1 job " "randread" 4096 1 1
run_fio "Rnd read,    4KB, QD=32, 1 job " "randread" 4096 32 1
run_fio "Rnd read,    4KB, QD=32, 4 jobs" "randread" 4096 32 4
run_fio "Rnd read,  128KB,  QD=1, 1 job " "randread" 131072 1 1
run_fio "Rnd read,  128KB, QD=32, 1 job " "randread" 131072 32 1
run_fio "Rnd read,  128KB, QD=32, 4 jobs" "randread" 131072 32 4
run_fio "Rnd read,  512KB,  QD=1, 1 job " "randread" 524288 1 1
run_fio "Rnd read,  512KB, QD=32, 1 job " "randread" 524288 32 1
run_fio "Rnd read,  512KB, QD=32, 4 jobs" "randread" 524288 32 4
run_fio "Rnd write,   4KB,  QD=1, 1 job " "randwrite" 4096 1 1
run_fio "Rnd write,   4KB, QD=32, 1 job " "randwrite" 4096 32 1
run_fio "Rnd write,   4KB, QD=32, 4 jobs" "randwrite" 4096 32 4
run_fio "Rnd write, 128KB,  QD=1, 1 job " "randwrite" 131072 1 1
run_fio "Rnd write, 128KB, QD=32, 1 job " "randwrite" 131072 32 1
run_fio "Rnd write, 128KB, QD=32, 4 jobs" "randwrite" 131072 32 4
run_fio "Seq read,  128KB,  QD=1, 1 job " "read" 131072 1 1
run_fio "Seq read,  128KB, QD=32, 1 job " "read" 131072 32 1
run_fio "Seq read,  512KB,  QD=1, 1 job " "read" 524288 1 1
run_fio "Seq read,  512KB, QD=32, 1 job " "read" 524288 32 1
run_fio "Seq read,    1MB, QD=32, 1 job " "read" 1048576 32 1
run_fio "Seq write, 128KB,  QD=1, 1 job " "write" 131072 1 1
run_fio "Seq write, 128KB, QD=32, 1 job " "write" 131072 32 1
run_fio "Seq write, 512KB,  QD=1, 1 job " "write" 524288 1 1
run_fio "Seq write, 512KB, QD=32, 1 job " "write" 524288 32 1
run_fio "Seq write,   1MB, QD=32, 1 job " "write" 1048576 32 1
run_fio "Rnd rdwr, 4K..1MB, QD=8, 4 jobs" "randrw" "4096-1048576" 8 4
