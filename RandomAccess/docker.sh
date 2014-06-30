#!/bin/sh

# just run this on arldcn24

# build the container 
make
docker rm gups
docker build -t gups .

mkdir -p results
log="results/docker.log"
now=`date`
echo "Running gups, started at $now"
echo "--------------------------------------------------------------------------------" >> $log
echo "Running gups, started at $now" >> $log
docker run gups >> $log
docker rm gups
echo "" >> $log
echo -n "Experiment completed at "; date
