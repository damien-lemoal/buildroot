#!/bin/bash

if [ $# != 1 ]; then
	echo "Usage: $0 <device>"
	exit 1
fi

dev="$1"
dev="$(realpath ${dev})"
if [ ! -b "${dev}" ]; then
	echo "${dev} is not a block device file"
	exit 1
fi

runtime=20

function run_fio()
{
	local name="$1"
	local rw="$2"
	local bs="$3"
	local qd=$4
	local nrjobs="$5"

	fiocmd="fio --name=\"${name}\" --filename=${dev}"
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

	if [ ${nrjobs} -gt 1 ]; then
		fiocmd="${fiocmd} --numjobs=${nrjobs}"
		fiocmd="${fiocmd} --cpus_allowed=0-$(( $(nproc) - 1 ))"
		fiocmd="${fiocmd} --cpus_allowed_policy=split"
		fiocmd="${fiocmd} --group_reporting=1"
	fi

	fiocmd="${fiocmd} --runtime=${runtime}"

	log="${name}.log"
	echo "  ${fiocmd}" > "${log}" 2>&1
	eval "${fiocmd}" >> "${log}" 2>&1

	grep IOPS "${log}" | cut -f-2 -d'(' | sed -e 's/^/    ->/'

	sync
}

echo "Running on ${dev}..."

echo "  Randread, 4KB, QD=1, 1 job"
run_fio "Randread-4k-1x1" "randread" 4096 1 1

echo "  Randread, 4KB, QD=32, 1 job"
run_fio "Randread-4k-1x32" "randread" 4096 32 1

echo "  Randread, 4KB, QD=32, 4 jobs"
run_fio "Randread-4k-4x32" "randread" 4096 32 4

echo "  Randread, 128KB, QD=32, 1 job"
run_fio "Randread-128k-1x32" "randread" 131072 32 1

echo "  Randread, 128KB, QD=32, 4 jobs"
run_fio "Randread-128k-4x32" "randread" 131072 32 4

echo "  Randread, 512KB, QD=32, 1 job"
run_fio "Randread-512k-1x32" "randread" 524288 32 1

echo "  Randread, 512KB, QD=32, 4 jobs"
run_fio "Randread-512k-4x32" "randread" 524288 32 4

echo "  Randwrite, 4KB, QD=32, 1 job"
run_fio "Randwrite-4k-1x32" "randwrite" 4096 32 1

echo "  Randwrite, 4KB, QD=32, 4 jobs"
run_fio "Randwrite-4k-4x32" "randwrite" 4096 32 4

echo "  Randwrite, 128KB, QD=32, 1 job"
run_fio "Randwrite-128k-1x32" "randwrite" 131072 32 1

echo "  Randwrite, 128KB, QD=32, 4 jobs"
run_fio "Randwrite-128k-4x32" "randwrite" 131072 32 4

echo "  Seq read, 128KB, QD=32, 1 job"
run_fio "Seqread-128k-1x32" "read" 131072 32 1

echo "  Seq read, 512KB, QD=32, 1 job"
run_fio "Seqread-512k-1x32" "read" 524288 32 1

echo "  Seq read, 1MB, QD=32, 1 job"
run_fio "Seqread-1M-1x32" "read" 1048576 32 1

echo "  Seq write, 128KB, QD=32, 1 job"
run_fio "Seqwrite-128k-1x32" "write" 131072 32 1

echo "  Seq write, 512KB, QD=32, 1 job"
run_fio "Seqwrite-512k-1x32" "write" 524288 32 1

echo "  Seq write, 1MB, QD=32, 1 job"
run_fio "Seqwrite-1M-1x32" "write" 1048576 32 1

echo "  Rand read/write, rand size 4K..1MB @ QD=8, 4 jobs"
run_fio "Randreadwrite-4k-1M-4x8" "randrw" "4096-1048576" 8 4
