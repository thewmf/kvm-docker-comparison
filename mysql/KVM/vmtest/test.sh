#!/bin/sh

# run this on arldcn24
# you need to be part of the kvm group; try sudo usermod -a -G kvm `whoami`

LIBDIR=../common/vm
SSHPORT=2222
SSHOPTS="-p$SSHPORT -i ../common/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oConnectionAttempts=60"
SCPOPTS="-P$SSHPORT -i ../common/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oConnectionAttempts=60"

# install mysql
cat <<EOF | ssh $SSHOPTS spyre@localhost
#mysqladmin -uroot -h127.0.0.1 -P3306 password 'supervisor'
#mysql -uroot -psupervisor -h127.0.0.1 -P3306 -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'supervisor'"
#mysql -uroot -psupervisor -h127.0.0.1 -P3306 -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"
mysql -uroot -psupervisor -h127.0.0.1 -P3306 -e "CREATE DATABASE test"
EOF
