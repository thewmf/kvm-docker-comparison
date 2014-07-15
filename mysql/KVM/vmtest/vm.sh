#!/bin/sh

# run this on arldcn24
# you need to be part of the kvm group; try sudo usermod -a -G kvm `whoami`

LIBDIR=../common/vm
SSHPORT=2222
SSHOPTS="-p$SSHPORT -i ../common/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oConnectionAttempts=60"
SCPOPTS="-P$SSHPORT -i ../common/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oConnectionAttempts=60"

# prepare source disk images
make -C $LIBDIR

# create ephemeral overlay qcow image
# (we probably could have used -snapshot)
IMG=`mktemp tmpXXX.img`
qemu-img create -f qcow2 -b $LIBDIR/ubuntu-13.10-server-cloudimg-amd64-disk1.img $IMG

# start the VM & bind port 2222 on the host to port 22 in the VM
# TODO use fancy virtio
kvm -net nic -net user -hda $IMG -hdb $LIBDIR/seed.img \
    -m 96G -smp 16 -nographic -redir :$SSHPORT::22 -redir :6616::3306 >$IMG.log &

# remove the overlay (qemu will keep it open as needed)
sleep 2
rm $IMG

# install mysql
scp $SCPOPTS mysql-opt.cnf spyre@localhost:.
cat <<EOF | ssh $SSHOPTS spyre@localhost
sudo apt-get update
sudo apt-get -qq install -y mysql-server < /dev/null
sudo mv mysql-opt.cnf /etc/mysql/conf.d
sudo /etc/init.d/mysql restart
mysqladmin -uroot -h127.0.0.1 -P3306 password 'supervisor'
mysql -uroot -psupervisor -h127.0.0.1 -P3306 -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'supervisor'"
mysql -uroot -psupervisor -h127.0.0.1 -P3306 -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"
mysql -uroot -psupervisor -h127.0.0.1 -P3306 -e "CREATE DATABASE test"
EOF

# mount /ferrari inside the VM
#ssh $SSHOPTS spyre@localhost "sudo sh -c 'mkdir /ferrari ; \
#                                          mount /dev/vda /ferrari ; \
#                                          chmod -R ugo+rwx /ferrari'"

#echo Running fio - this takes 5-10 minutes
#ssh $SSHOPTS spyre@localhost fio - < test.fio > results/vm.log

# shut down the VM
#ssh $SSHOPTS spyre@localhost sudo shutdown -h now

#wait
#echo Experiment completed

