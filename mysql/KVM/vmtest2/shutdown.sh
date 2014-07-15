#!/bin/sh

# run this on arldcn24
# you need to be part of the kvm group; try sudo usermod -a -G kvm `whoami`

LIBDIR=../common/vm
SSHPORT=22
SSHOPTS="-p$SSHPORT -i ../common/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oConnectionAttempts=60"
SCPOPTS="-P$SSHPORT -i ../common/id_rsa -oUserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no -oConnectionAttempts=60"

# install mysql
ssh $SSHOPTS spyre@10.71.1.99 "sudo shutdown -h now" 
