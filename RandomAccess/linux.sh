#!/bin/sh

# just run this on arldcn24

# build the code 
make

now=`date`
echo "Running gups, started at $now"
echo "--------------------------------------------------------------------------------" >> results/linux.log
echo "Running gups, started at $now" >> results/linux.log
time numactl --physcpubind=0-7,16-23 --localalloc ./bin/gups.exe >> results/linux.log
echo "" >> results/linux.log
echo -n "Experiment completed at "; date
