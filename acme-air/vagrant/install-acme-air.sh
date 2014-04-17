#!/bin/bash

# inside the VM
sudo apt-get -y install nodejs nodejs-legacy mongodb git screen npm supervisor
 
#create directory to get acme air
mkdir code
cd code
git clone https://github.com/acmeair/acmeair.git
export ACMEAIR_SRCDIR=/home/vagrant/code/acmeair
cd $ACMEAIR_SRCDIR/acmeair-webapp-nodejs
sed -e 's/3.0.0beta7/3.3.7/' package.json  > package.json.new
mv package.json.new package.json
npm update
cd $ACMEAIR_SRCDIR/acmeair-webapp-nodejs/loader
node loader
sudo service mongodb force-stop
sudo service supervisor force-stop
sleep 10
sudo killall -9 mongod
sudo killall -9 supervisord

if [ -e /etc/supervisor/supervisor.conf ] 
then
	mv /etc/supervisor/supervisor.conf  /etc/supervisor/supervisor.conf.old
fi
cat <<EOF > /etc/supervisor/supervisor.conf
[supervisord]
nodaemon=true
#[program:sshd]
#command=/usr/sbin/sshd -D
#stdout_logfile=/var/log/supervisor/%(program_name)s.log
#stderr_logfile=/var/log/supervisor/%(program_name)s.log
#autorestart=true
[program:mongod]
user=mongodb
command=/usr/bin/mongod --config /etc/mongodb.conf
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s.log
autorestart=true
[program:acme-air]
user=vagrant
directory=/home/vagrant/code/acmeair/acmeair-webapp-nodejs
command=node app
stdout_logfile=/var/log/supervisor/%(program_name)s.log
stderr_logfile=/var/log/supervisor/%(program_name)s.log
autorestart=true
EOF
