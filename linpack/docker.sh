#!/bin/sh

SUT=arldcn24
DIR=`pwd`

# build the container (assumes the spyre git repo is in NFS)
ssh $SUT docker build -t linpack $DIR

# run the test

echo Running linpack - this takes 10-15 minutes
ssh $SUT docker run --rm linpack > results/docker.log

wait
echo Experiment completed
