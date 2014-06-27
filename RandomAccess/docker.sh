#!/bin/sh

# just run this on arldcn24

# build the container 
make
docker rm gups
docker build -t gups .

echo Running gups
now=`date "+%s"`
mv results/docker.log results/docker.log.placedHere.$now
docker run gups > results/docker.log
docker rm gups

echo Experiment completed
