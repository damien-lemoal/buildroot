#!/bin/bash

logdir="/root/pci-ep/fio-tests-logs"

# Default arguments
dev=""
runtime=20
ramptime=0
sched="none"
runtest=0

# Number of runs defined
nrtests=26

# fio runs definition: title, rw, bs, iodepth, numjobs
test1=" \"Rnd read,    4KB,  QD=1, 1 job \" \"randread\"  4096 1 1"
test2=" \"Rnd read,    4KB, QD=32, 1 job \" \"randread\"  4096 32 1"
test3=" \"Rnd read,    4KB, QD=32, 4 jobs\" \"randread\"  4096 32 4"
test4=" \"Rnd read,  128KB,  QD=1, 1 job \" \"randread\"  131072 1 1"
test5=" \"Rnd read,  128KB, QD=32, 1 job \" \"randread\"  131072 32 1"
test6=" \"Rnd read,  128KB, QD=32, 4 jobs\" \"randread\"  131072 32 4"
test7=" \"Rnd read,  512KB,  QD=1, 1 job \" \"randread\"  524288 1 1"
test8=" \"Rnd read,  512KB, QD=32, 1 job \" \"randread\"  524288 32 1"
test9=" \"Rnd read,  512KB, QD=32, 4 jobs\" \"randread\"  524288 32 4"
test10="\"Rnd write,   4KB,  QD=1, 1 job \" \"randwrite\" 4096 1 1"
test11="\"Rnd write,   4KB, QD=32, 1 job \" \"randwrite\" 4096 32 1"
test12="\"Rnd write,   4KB, QD=32, 4 jobs\" \"randwrite\" 4096 32 4"
test13="\"Rnd write, 128KB,  QD=1, 1 job \" \"randwrite\" 131072 1 1"
test14="\"Rnd write, 128KB, QD=32, 1 job \" \"randwrite\" 131072 32 1"
test15="\"Rnd write, 128KB, QD=32, 4 jobs\" \"randwrite\" 131072 32 4"
test16="\"Seq read,  128KB,  QD=1, 1 job \" \"read\"      131072 1 1"
test17="\"Seq read,  128KB, QD=32, 1 job \" \"read\"      131072 32 1"
test18="\"Seq read,  512KB,  QD=1, 1 job \" \"read\"      524288 1 1"
test19="\"Seq read,  512KB, QD=32, 1 job \" \"read\"      524288 32 1"
test20="\"Seq read,    1MB, QD=32, 1 job \" \"read\"      1048576 32 1"
test21="\"Seq write, 128KB,  QD=1, 1 job \" \"write\"     131072 1 1"
test22="\"Seq write, 128KB, QD=32, 1 job \" \"write\"     131072 32 1"
test23="\"Seq write, 512KB,  QD=1, 1 job \" \"write\"     524288 1 1"
test24="\"Seq write, 512KB, QD=32, 1 job \" \"write\"     524288 32 1"
test25="\"Seq write,   1MB, QD=32, 1 job \" \"write\"     1048576 32 1"
test26="\"Rnd rdwr, 4K..1MB, QD=8, 4 jobs\" \"randrw\"    \"4096-1048576\" 8 4"

function usage()
{
	echo "Usage: ${cmd} [Arguments]"
	echo "Arguments:"
	echo "  -h | --help         : Print this help message"
	echo "  -l | --list         : List test cases"
	echo "  -t | --tests <num>  : Run only test case #num"
	echo "  --dev <device>      : Specify the device to test"
	echo "                        (Default: nvme-Linux-pci-epf device)"
	echo "  --sched <sched>     : Set I/O scheduler (default: ${sched})"
	echo "  --runtime <secs>    : Specify fio run time"
	echo "                        (Default: ${runtime} seconds)"
	echo "  --ramptime <secs>   : Specify fio ramp time"
	echo "                        (Default: ${ramptime} seconds)"
}

function list_runs()
{
	echo "Test cases: (title, rw, bs, iodepth, numjobs)"
        for t in $(seq 1 ${nrtests}); do
                eval case="\$test${t}"
                echo "Test ${t}: $(echo "${case}" | sed -n 's/^[^"]*"\([^"]*\)".*/\1/p')"
        done
}

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
	fiocmd="${fiocmd} --ioscheduler=${sched}"

	if [ ${qd} -eq 1 ]; then
		fiocmd="${fiocmd} --ioengine=psync"
	else
		fiocmd="${fiocmd} --ioengine=io_uring --iodepth=${qd}"
	fi

	range=$(echo ${bs} | grep -c "-")
	if [ ${range} -eq 0 ]; then
		fiocmd="${fiocmd} --bs=${bs}"
	else
		fiocmd="${fiocmd} --bsrange=${bs}"
	fi

	fiocmd="${fiocmd} --numjobs=${nrjobs}"
	fiocmd="${fiocmd} --cpus_allowed=0-$(( $(nproc) - 1 ))"
	fiocmd="${fiocmd} --cpus_allowed_policy=split"
	fiocmd="${fiocmd} --group_reporting=1"
	fiocmd="${fiocmd} --norandommap=1 --random_generator=tausworthe64"
	fiocmd="${fiocmd} --runtime=${runtime}"

	if [ ${ramptime} -ne 0 ]; then
		fiocmd="${fiocmd} --ramp_time=${ramptime}"
	fi

	log="${name}.log"
	echo "  ${fiocmd}" > "${log}" 2>&1

	echo -n "  ${title}: "

	eval "${fiocmd}" >> "${log}" 2>&1

	grep IOPS "${log}" | cut -f-2 -d'(' | sed -e 's/^//' | cut -f2- -d':'

	sync
}

while [ $# -ne 0 ]; do
	case "$1" in
	-h | --help)
		usage
		exit 0
		;;
	-l | --list)
		list_runs
		exit 0
		;;
	--test)
		shift
		runtest=$1
		shift
		;;

	--dev)
		shift
		dev="$(realpath $1)"
		shift
		;;
	--sched)
		shift
		sched="$1"
		shift
		;;
	--runtime)
		shift
		runtime=$1
		shift
		;;
	--ramptime)
		shift
		ramptime=$1
		shift
		;;
	-*)
		echo "unknow option $1"
		exit 1
		;;
	esac
done

if [ $# -ne 0 ]; then
	echo "Invalid command line"
	usage
	exit 1
fi

if [ "${dev}" == "" ]; then
	devid="$(ls /dev/disk/by-id/ | grep nvme-Linux-pci-epf | tail -1)"
	dev="$(realpath "/dev/disk/by-id/${devid}")"
else
	dev="$(realpath ${dev})"
fi

if [ ! -b "${dev}" ]; then
        echo "${dev} is not a block device file"
        exit 1
fi

if [ ${runtime} -lt 0 ]; then
	echo "Invalid run time"
	exit 1
fi

if [ ${runtest} -gt ${nrtests} ]; then
	echo "Invalid run test ${runtest}"
	exit 1
fi

# Execute the runs
mkdir -p "${logdir}"

echo "Running on ${dev} (${ramptime}+${runtime} secs run time, ${sched} scheduler)..."

if [ ${runtest} -ne 0 ]; then
	# Run only the specified test case
	eval case="\$test${runtest}"
	eval "run_fio ${case}"
else
	# Run all test cases
	for t in $(seq 1 ${nrtests}); do
		eval case="\$test${t}"
		eval "run_fio ${case}"
	done
fi
