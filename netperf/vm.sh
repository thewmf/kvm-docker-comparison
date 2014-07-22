#!/bin/sh

SERVER=arldcn24
CLIENT=arldcn28

# run this on arldcn24
# you need to be part of the kvm group; try sudo usermod -a -G kvm `whoami`

LIBDIR=../common/vm
SSHOPTS="-i ../common/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oConnectionAttempts=60"
VMIP=10.71.1.99

# prepare source disk images
make -C $LIBDIR

# create ephemeral overlay qcow image
# (we probably could have used -snapshot)
IMG='netperf.qcow'
rm -f $IMG
qemu-img create -f qcow2 -b $LIBDIR/ubuntu-13.10-server-cloudimg-amd64-disk1.img $IMG

# clean out any old VM
sudo virsh destroy netperf
# start the VM
date
sudo virsh create virsh.xml

# remove the overlay (qemu will keep it open as needed)
sleep 2
rm -f $IMG

ssh $SSHOPTS spyre@$VMIP echo hello VM
date

# ssh $SSHOPTS spyre@$VMIP ifconfig -a
ssh $SSHOPTS spyre@$VMIP "route && ping -c2 10.71.1.28"

# install netperf
#ssh $SSHOPTS spyre@$VMIP sudo bash -c 'echo "deb http://archive.ubuntu.com/ubuntu saucy multiverse" \>\> /etc/apt/sources.list'

#ssh $SSHOPTS spyre@$VMIP cat /etc/apt/sources.list

#ssh $SSHOPTS spyre@$VMIP sudo apt-get update

#ssh $SSHOPTS spyre@$VMIP sudo apt-get -qq install -y nuttcp netperf
# after installing, netserver is automatically running from inetd

# install netperf  ... the hard way
scp $SSHOPTS `which netserver` spyre@$VMIP:~
ssh $SSHOPTS spyre@$VMIP sudo ./netserver -v -p 12865 &
sleep 2

echo "TCP_RR"
ssh $CLIENT netperf -l 60 -H 10.71.1.99 -t TCP_RR -- -r 100,200
ssh $CLIENT netperf -l 60 -H 10.71.1.99 -t TCP_RR -- -r 100,200
ssh $CLIENT netperf -l 60 -H 10.71.1.99 -t TCP_RR -- -r 100,200
ssh $CLIENT netperf -l 60 -H 10.71.1.99 -t TCP_RR -- -r 100,200
ssh $CLIENT netperf -l 60 -H 10.71.1.99 -t TCP_RR -- -r 100,200

echo "UDP_RR"
ssh $CLIENT netperf -l 60 -H 10.71.1.99 -t UDP_RR -- -r 100,200
ssh $CLIENT netperf -l 60 -H 10.71.1.99 -t UDP_RR -- -r 100,200
ssh $CLIENT netperf -l 60 -H 10.71.1.99 -t UDP_RR -- -r 100,200
ssh $CLIENT netperf -l 60 -H 10.71.1.99 -t UDP_RR -- -r 100,200
ssh $CLIENT netperf -l 60 -H 10.71.1.99 -t UDP_RR -- -r 100,200

# TODO copy out results

# shut down the VM
ssh $SSHOPTS spyre@$VMIP sudo shutdown -h now
sleep 5
sudo virsh destroy netperf

wait
echo Experiment completed
