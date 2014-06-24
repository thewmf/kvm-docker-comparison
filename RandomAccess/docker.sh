#!/bin/sh

# just run this on arldcn24

# build the container 
make
docker build -t gups .

echo Running gups
docker run --rm gups > results/docker.log

wait
echo Experiment completed
