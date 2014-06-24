#!/bin/sh

# just run this on arldcn24

# build the container 
make
docker rm gups
docker build -t gups .

echo Running gups
docker run gups
docker cp gups:/RESULTS results/docker.log
docker rm gups

wait
echo Experiment completed
