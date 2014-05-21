#!/bin/sh

SERVER=arldcn28
CLIENT=arldcn24
DIR=`pwd`

# TODO set up networking on the server
ssh $SERVER nuttcp -S &

# TODO set up bridge on the client

# build the container (assumes the spyre git repo is in NFS)
ssh $CLIENT sudo docker build -t nuttcp $DIR

# transmit client->server
ssh $CLIENT docker --net=host run nuttcp -l8000 -t -w4m -i1 -N4 10.71.0.28
# receive server->client (this matters because we only measure the client)
ssh $CLIENT docker --net=host run nuttcp -l8000 -r -w4m -i1 -N4 10.71.0.28

# clean up
ssh $SERVER killall nuttcp

wait
echo Experiment completed
