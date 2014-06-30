#!/bin/sh

# just run this on arldcn24

# build the container 
make
docker build -t stream .

echo Running stream
# now=`date "+%s"`
# mv results/docker.log results/docker.log.placedHere.$now
docker run stream >> results/docker.log
# can't get this stuff to work and can't find docs anywhere
#ID=$(docker run stream)
#docker cp $ID:/RESULTS results/
#mv results/RESULTS results/docker.log
#docker rm $ID

wait
echo Experiment completed
