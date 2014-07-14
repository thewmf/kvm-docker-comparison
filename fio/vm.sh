#!/bin/sh

# run this on arldcn24
# you need to be part of the kvm group; try sudo usermod -a -G kvm `whoami`

LIBDIR=../common/vm
SSHOPTS="-p2222 -i ../common/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oConnectionAttempts=60"

# prepare source disk images
make -C $LIBDIR

# create ephemeral overlay qcow image
# (we probably could have used -snapshot)
IMG=`mktemp tmpXXX.img`
qemu-img create -f qcow2 -b $LIBDIR/ubuntu-13.10-server-cloudimg-amd64-disk1.img $IMG

# unmount /ferrari on the host because we're going to mount it inside the VM
sudo umount /ferrari

# start the VM & bind port 2222 on the host to port 22 in the VM
# TODO use fancy virtio
kvm -net nic -net user -hda $IMG -hdb $LIBDIR/seed.img \
    -drive file=/dev/mapper/FlashSystem_840,if=virtio,cache=none,aio=native \
    -m 96G -smp 32 -nographic -redir :2222::22 >$IMG.log &

# remove the overlay (qemu will keep it open as needed)
sleep 2
rm $IMG

# install fio
ssh $SSHOPTS spyre@localhost sudo apt-get -qq install -y fio

# mount /ferrari inside the VM
ssh $SSHOPTS spyre@localhost "sudo sh -c 'mkdir /ferrari ; \
                                          mount /dev/vda /ferrari ; \
                                          chmod -R ugo+rwx /ferrari'"

echo Running fio - this takes 5-10 minutes
ssh $SSHOPTS spyre@localhost fio - < test.fio > results/vm.log

# shut down the VM
ssh $SSHOPTS spyre@localhost sudo shutdown -h now

wait
echo Experiment completed
