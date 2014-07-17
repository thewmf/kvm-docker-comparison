#!/bin/sh

SERVER=arldcn24
CLIENT=arldcn28

# Make sure to run this on $SERVER
hostname|grep $SERVER > /dev/null
if [ $? -ne 0 ]; then
  echo "You need to run this script in $SERVER"
  exit -2
fi
# Note: you need to be part of the kvm group; try: sudo usermod -a -G kvm `whoami`

LIBDIR=../../common/vm
SSHOPTS="-i ../../common/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oConnectionAttempts=60"
VMIP=10.71.1.99

# prepare source disk images
make -C $LIBDIR

# create ephemeral overlay qcow image
# (we probably could have used -snapshot)
IMG='redis.qcow'
rm -f $IMG
qemu-img create -f qcow2 -b $LIBDIR/ubuntu-13.10-server-cloudimg-amd64-disk1.img $IMG

# clean out any old VM
sudo virsh destroy redis
# start the VM
#JCR: Unclear the following cmd needs sudo
sudo virsh create virsh.xml

echo "[DBG] wait for VM to start, then remove the overlay (qemu will keep it open as needed)"
sleep 15
rm -f $IMG

# ====================================================================
#echo "[DBG] Configure the client"
#ssh $USER@$CLIENT "rm -rf /tmp/$USER/redis ; mkdir -p /tmp/$USER/redis"
#scp -p ../container/redis/pack.tar.gz $USER@$CLIENT:/tmp/$USER/redis/
#ssh $USER@$CLIENT "cd /tmp/$USER/redis ; tar -xvf pack.tar.gz"

# --------------------------------------
echo "[DBG] Make sure CPUs are in performance mode"
for x in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do sudo sh -c "echo performance > $x"; done

# --------------------------------------
echo "[DBG] Install and start Redis in server"
ssh $SSHOPTS spyre@$VMIP "mkdir -p /tmp/redis"
scp $SSHOPTS -p ../container/redis/pack.tar.gz spyre@$VMIP:/tmp/redis
ssh $SSHOPTS spyre@$VMIP "cd /tmp/redis && tar -xvf pack.tar.gz"
ssh $SSHOPTS spyre@$VMIP "cd /tmp/redis/SOURCE/redis-2.8.13-x86_64-Ubuntu-13.10/ && ./src/redis-server --daemonize yes --bind $VMIP --port 6379"

# --------------------------------------
echo "[DBG] Test connection between server and client"
# ssh $SSHOPTS spyre@$VMIP ifconfig -a
ssh $SSHOPTS spyre@$VMIP   "route && ping -c2 10.71.1.28"
ssh          $USER@$CLIENT "route && ping -c2 10.71.1.24"

# --------------------------------------
# --------------------------------------
echo "Now run your experiments.  Then remove the VM with:"
echo "  sudo virsh destroy redis"
exit
# --------------------------------------
# --------------------------------------

echo "[DBG] TCP transmit client->server basic"
ssh $SSHOPTS spyre@$VMIP redis -t 10.71.1.28
#ssh $SSHOPTS spyre@$VMIP redis -t -i1 10.71.1.28
#ssh $SSHOPTS spyre@$VMIP redis -t -i1 -w4m 10.71.1.28

echo "[DBG] TCP receive server->client (this matters because we only measure the client)"
ssh $SSHOPTS spyre@$VMIP redis -r 10.71.1.28

# TODO copy out results

# shut down the VM
ssh $SSHOPTS spyre@$VMIP sudo shutdown -h now
sleep 5
exit
sudo virsh destroy redis

wait
echo Experiment completed
