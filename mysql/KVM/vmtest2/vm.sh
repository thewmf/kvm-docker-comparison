#!/bin/sh

SERVER=arldcn28
CLIENT=arldcn24

# run this on arldcn24
# you need to be part of the kvm group; try sudo usermod -a -G kvm `whoami`

LIBDIR=../common/vm
SSHOPTS="-i ../common/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oConnectionAttempts=60"
SCPOPTS="-i ../common/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oConnectionAttempts=60"
VMIP=10.71.1.99

# prepare source disk images
make -C $LIBDIR

# create ephemeral overlay qcow image
# (we probably could have used -snapshot)
IMG='mysql.qcow'
rm -f $IMG
qemu-img create -f qcow2 -b $LIBDIR/ubuntu-13.10-server-cloudimg-amd64-disk1.img $IMG

# clean out any old VM
virsh destroy mysql
# start the VM
virsh create virsh.xml

# remove the overlay (qemu will keep it open as needed)
sleep 2
rm -f $IMG

# install mysql
scp $SCPOPTS mysql-opt.cnf mysql-initialize.sh spyre@$VMIP:.
echo "Executing the instalation remotely" 
ssh $SSHOPTS spyre@$VMIP "bash mysql-initialize.sh" 
echo "Finished the instalation remotely" 

echo "Waiting for the test to complete, type enter to finish"
read a
echo "Finishing the VM"

# shut down the VM
ssh $SSHOPTS spyre@$VMIP sudo shutdown -h now
sleep 5
sudo virsh destroy mysql

wait
