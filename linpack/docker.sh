#!/bin/sh

# Set up the dockerfile
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 numberOfSockets (specify as 1 or 2)" 
    exit 1
fi

if [ "$1" -eq 1 ]; then
    rm -f Dockerfile
    ln -s Dockerfile.oneSocket Dockerfile
elif [ "$1" -eq 2 ]; then
    rm -f Dockerfile
    ln -s Dockerfile.twoSocket Dockerfile
else
    echo "Usage: $0 numberOfSockets (specify as 1 or 2)" 
    exit 1
fi

# SUT=arldcn24
DIR=`pwd`

# Don't make the executable - we got it from intel

# build the container (assumes the spyre git repo is in NFS)
docker build -t linpack $DIR

# run the test

mkdir -p results
log="results/docker.log"
now=`date`
echo "Running linpack, started at $now"
echo "--------------------------------------------------------------------------------" >> $log
echo "Running linpack, started at $now" >> $log
docker run --rm linpack >> $log

echo "" >> $log
echo -n "Experiment completed at "; date
