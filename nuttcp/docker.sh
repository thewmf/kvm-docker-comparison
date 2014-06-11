#!/bin/sh

SERVER=arldcn28
CLIENT=arldcn24
DIR=`pwd`

# TODO set up networking on the server
ssh $SERVER "sudo ifconfig mezz0 10.71.0.28 up; sudo sh -c 'echo 4194304 > /proc/sys/net/core/wmem_max ; echo 4194304 > /proc/sys/net/core/rmem_max'; nuttcp -S" &

# TODO set up bridge on the client
ssh $CLIENT "sudo ifconfig mezz0 10.71.0.24 up; sudo sh -c 'echo 4194304 > /proc/sys/net/core/wmem_max ; echo 4194304 > /proc/sys/net/core/rmem_max'"

# build the container (assumes the spyre git repo is in NFS)
ssh $CLIENT docker build -t nuttcp $DIR

# transmit client->server
ssh $CLIENT docker run nuttcp -l8000 -t -w4m -i1 -N4 10.71.0.28

# receive server->client (this matters because we only measure the client)
# XXX this doesn't work due to NAT?
#ssh $CLIENT docker run nuttcp -l8000 -r -w4m -i1 -N4 10.71.0.28

# clean up
ssh $SERVER killall nuttcp

wait
echo Experiment completed
