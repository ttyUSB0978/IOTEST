#!/bin/bash

THISUSER=`whoami`
if [ "x$THISUSER" != "xroot" ]; then
	echo "This script requires root privilege"
	exit 1
fi

showUsage() {

	echo "Usage: sudo ./iotest.sh <disk partition>"
	echo "example: sudo ./iotest.sh /dev/sda1"
}

DEVICE=$1
#echo "arg = $1"

if [ ! -n "${DEVICE}" ]; then
	showUsage
	#DEVICE=/dev/mmcblk0p1
	exit 1
fi

echo "Device= $DEVICE"

CHECKSTRING=`sudo fdisk -l ${DEVICE} 2>&1 | awk '/cannot/'`

echo $CHECKSTRING

if [[ ${CHECKSTRING} == *"cannot"* ]]; then
	echo "ERROR: cannot find this partition."
	exit 1
fi


RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'


WRITE=0
READ=0

printf  "***${RED}~writing test~${NC}***\n"
echo  "testing...  "

for ((i=1; i<=10; i++)); do

	WRITESTRING=`dd if=$DEVICE of=/tmp/output.img bs=128k count=512 oflag=direct 2>&1 | awk '/bytes/{print $(NF-1)}'`
	WRITE=$(bc -l <<<"$WRITESTRING + $WRITE")
	echo "TEST $i: $WRITESTRING MB/s"

done

RESULT_W=$(bc <<<"${WRITE}/10")  

printf "average: ${YELLOW}$((${RESULT_W})) MB/s${NC}\n"

printf "***${BLUE}~reading test~${NC}***\n"
echo "testing...  "

#dd if=/tmp/output.img of=$DEVICE bs=128k count=512 2>&1 | awk '/bytes/{print $(NF-1), $NF}'

for ((i=1; i<=10; i++)); do

	READSTRING=`dd if=/tmp/output.img of=$DEVICE bs=256k count=1024 oflag=direct 2>&1 | awk '/bytes/{print $(NF-1)}'`
	READ=$(bc -l <<<"$READSTRING + $READ")
	echo "TEST $i: $READSTRING MB/s"

done

RESULT_R=$(bc <<<"${READ}/10")
rm /tmp/output.img

printf "average: ${YELLOW}$((${RESULT_R})) MB/s${NC}\n"

