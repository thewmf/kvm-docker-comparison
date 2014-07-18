#!/bin/sh

# server and client are reversed compared to nuttcp
SERVER=arldcn24
CLIENT=arldcn28
DIR=`pwd`

# build the container (assumes the spyre git repo is in NFS)
cp /usr/bin/netserver .
ssh $CLIENT docker build -t netserver $DIR

sudo service netperf stop
ssh $SERVER docker run -d -p 12865:12865 netserver

ssh $CLIENT netperf -l 60 -H 10.71.0.24 -t TCP_RR -- -r 100,200
ssh $CLIENT netperf -l 60 -H 10.71.0.24 -t UDP_RR -- -r 100,200

# clean up
#ssh $SERVER docker stop netserver

wait
echo Experiment completed
