#!/bin/sh

# just run this on arldcn24

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


# build the executable
make

# build the container 
docker rm gups:latest
docker build -t gups .

mkdir -p results
log="results/docker.log"
now=`date`
echo "Running gups, started at $now"
echo "--------------------------------------------------------------------------------" >> $log
echo "Running gups, started at $now" >> $log
docker run --rm gups >> $log
docker rm gups
echo "" >> $log
echo -n "Experiment completed at "; date
