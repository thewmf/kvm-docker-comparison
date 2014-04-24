#!/bin/bash
kvm -net nic -net user -hda play.img -hdb seed.img -m 1G -nographic -redir :2222::22

# in another window:
# ssh-keygen -f "/power/home/wmf/.ssh/known_hosts" -R [localhost]:2222
# ssh -p 2222 -i ../id_rsa -o StrictHostKeyChecking=no -o CheckHostIP=no spyre@localhost
# or you can login at the QEMU console:
# press enter a few times after It's aliiiiiive
# when done, press ctrl-a c then system_powerdown