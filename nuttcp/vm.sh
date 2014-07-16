#!/bin/sh

SERVER=arldcn28
CLIENT=arldcn24

# run this on arldcn24
# you need to be part of the kvm group; try sudo usermod -a -G kvm `whoami`

LIBDIR=../common/vm
SSHOPTS="-i ../common/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oConnectionAttempts=60"
VMIP=10.71.1.99

# prepare source disk images
make -C $LIBDIR

# create ephemeral overlay qcow image
# (we probably could have used -snapshot)
IMG='nuttcp.qcow'
rm -f $IMG
qemu-img create -f qcow2 -b $LIBDIR/ubuntu-13.10-server-cloudimg-amd64-disk1.img $IMG

# clean out any old VM
sudo virsh destroy nuttcp
# start the VM
sudo virsh create virsh.xml

# remove the overlay (qemu will keep it open as needed)
sleep 2
rm -f $IMG

# TODO set up networking on the server
ssh $SERVER nuttcp -S &

# install nuttcp
ssh $SSHOPTS spyre@$VMIP sudo apt-get -qq install -y nuttcp

# ssh $SSHOPTS spyre@$VMIP ifconfig -a

ssh $SSHOPTS spyre@$VMIP "route && ping -c2 10.71.1.28"

echo "TCP transmit client->server basic"
ssh $SSHOPTS spyre@$VMIP nuttcp -t 10.71.1.28
#ssh $SSHOPTS spyre@$VMIP nuttcp -t -i1 10.71.1.28
#ssh $SSHOPTS spyre@$VMIP nuttcp -t -i1 -w4m 10.71.1.28

echo "TCP receive server->client (this matters because we only measure the client)"
ssh $SSHOPTS spyre@$VMIP nuttcp -r 10.71.1.28

#echo "UDP transmit client->server basic"
#ssh $SSHOPTS spyre@$VMIP nuttcp -t -u 10.71.1.28
#ssh $SSHOPTS spyre@$VMIP nuttcp -t -u -l1 10.71.1.28

#echo "UDP receive server->client (this matters because we only measure the client)"
#ssh $SSHOPTS spyre@$VMIP nuttcp -r -u 10.71.1.28
#ssh $SSHOPTS spyre@$VMIP nuttcp -r -u -l1 10.71.1.28

# TODO copy out results

# shut down the VM
ssh $SSHOPTS spyre@$VMIP sudo shutdown -h now
sleep 5
sudo virsh destroy nuttcp

wait
echo Experiment completed
