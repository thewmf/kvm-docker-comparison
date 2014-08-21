#!/bin/sh

# run this on a Linux machine like arldcn24,28


if [ "$#" -ne 1 ]; then
    echo "Usage: $0 numberOfSockets (specify as 1 or 2)" 
    exit 1
fi

if [ "$1" -eq 1 ]; then
    numaopts=" --physcpubind=0-7,16-23 --localalloc "
	numsmp=16
    echo "Running on one socket with numactl $numaopts"
elif [ "$1" -eq 2 ]; then
    numaopts=" --physcpubind=0-31 --interleave=0,1 "
	numsmp=32
    echo "Running on two sockets with numactl $numaopts"
else
    echo "Usage: $0 numberOfSockets (specify as 1 or 2)" 
    exit 1
fi

LIBDIR=../common/vm
SSHOPTS="-i ../common/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oConnectionAttempts=60"
VMIP=10.71.1.99

# prepare source disk images
make -C $LIBDIR

# create ephemeral overlay qcow image
# (we probably could have used -snapshot)
IMG=linpack.qcow
qemu-img create -f qcow2 -b $LIBDIR/ubuntu-13.10-server-cloudimg-amd64-disk1.img $IMG

# start the VM & bind port 2222 on the host to port 22 in the VM
#numactl $numaopts kvm -net nic -net user -hda $IMG -hdb $LIBDIR/seed.img -m 100G -smp $numsmp \
#    -nographic -redir :2222::22 >$IMG.log &

# clean out any old VM
sudo virsh destroy linpack
# start the VM
# -- WARNING WARNING WARNING virsh.xml is hardcoded to wmf's home directory --
sudo virsh create virsh.xml

# remove the overlay (qemu will keep it open as needed)
sleep 2
rm -f $IMG

# look at the topology
ssh $SSHOPTS spyre@$VMIP sudo apt-get install -y hwloc
ssh $SSHOPTS spyre@$VMIP lstopo --of console > results/vm.tuned.topo

# copy code in (we could use Ansible for this kind of thing, but...)
rsync -a -e "ssh $SSHOPTS" bin/ spyre@$VMIP:~

# annotate the log
mkdir -p results
log="results/vm.log"
now=`date`
echo "Running linpack, started at $now"
echo "--------------------------------------------------------------------------------" >> $log
echo "Running linpack, started at $now" >> $log

# run linpack
ssh $SSHOPTS spyre@$VMIP ./runme_xeon64 >> $log

# annotate the log
echo "" >> $log
echo -n "Experiment completed at "; date

# shut down the VM
ssh $SSHOPTS spyre@$VMIP sudo shutdown -h now

wait
echo Experiment completed
