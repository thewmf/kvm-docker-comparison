#!/bin/sh

SERVER=arldcn28
CLIENT=arldcn24
DIR=`pwd`

# TODO set up networking on the server
#ssh $SERVER "sudo sh -c 'echo 4194304 > /proc/sys/net/core/wmem_max ; \
#                         echo 4194304 > /proc/sys/net/core/rmem_max ; \
#                         ip addr add 10.71.0.28/24 dev mezz0 ;
#                      	 ip addr add 10.71.2.28/24 dev mezz0 ;
#                         '; \
#             nuttcp -S" &

# TODO set up bridge on the client
#ssh $CLIENT "sudo sh -c 'echo 4194304 > /proc/sys/net/core/wmem_max ; \
#                         echo 4194304 > /proc/sys/net/core/rmem_max ; \
#                         ip addr add 10.71.0.24/24 dev mezz0 ;
#                         brctl addbr vanilla ;
#                         ip link set vanilla up ;
#                         brctl addif vanilla mezz0 ;
#                         '"

# build the container (assumes the spyre git repo is in NFS)
ssh $CLIENT docker build -t nuttcp $DIR

# transmit client->server
echo "client to server (native)"
ssh $CLIENT sudo perf stat -a nuttcp -t 10.71.0.28

echo "client to server (Docker NAT)"
ssh $CLIENT sudo perf stat -a docker run nuttcp -t 10.71.0.28

#echo "client to server (bridged)"
#ssh $CLIENT pipework vanilla $(docker run -d nuttcp -l8000 -t -w4m -i1 -N1 10.71.1.28) 10.71.1.24

# receive server->client (this matters because we only measure the client)
echo "server to client (Docker NAT)"
ssh $CLIENT docker run -p 5000:5000 -p 5001:5001 nuttcp -P5000 -p5001-r 10.71.0.28

# clean up
ssh $SERVER killall nuttcp

wait
echo Experiment completed
