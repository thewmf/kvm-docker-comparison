#!/bin/sh

# just run this on arldcn24

# build the container 
make
docker build -t stream .

echo Running stream
docker run --rm stream > results/docker.log

wait
echo Experiment completed
