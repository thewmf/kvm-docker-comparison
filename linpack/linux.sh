#!/bin/sh

# just run this on arldcn24

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 numberOfSockets (specify as 1 or 2)" 
    exit 1
fi

if [ "$1" -eq 1 ]; then
    numaopts=" --physcpubind=0-7,16-23 --localalloc "
    echo "Running on one socket with numactl $numaopts"
elif [ "$1" -eq 2 ]; then
    numaopts=" --physcpubind=0-31 --interleave=0,1 "
    echo "Running on two sockets with numactl $numaopts"
else
    echo "Usage: $0 numberOfSockets (specify as 1 or 2)" 
    exit 1
fi

# There is no code to build 
# make

now=`date`
echo "Running linpack, started at $now"
echo "--------------------------------------------------------------------------------" >> results/linux.log
echo "Running linpack with numaopts < $numaopts >, started at $now" >> results/linux.log
cd bin
time numactl $numaopts ./runme_xeon64 >> ../results/linux.log


echo "" >> ../results/linux.log
echo -n "Experiment completed at "; date
