# In production this should probably be busybox, but let's use ubuntu for a
# fair comparison 
FROM tutum/ubuntu-saucy

MAINTAINER Wes Felter, wmf@us.ibm.com

# The apt sources config file contains:
#    deb http://archive.ubuntu.com/ubuntu saucy main universe
#    deb http://archive.ubuntu.com/ubuntu saucy-updates main universe
#    deb http://archive.ubuntu.com/ubuntu saucy-security main universe
# Restricted to reduce update time
RUN echo "deb http://archive.ubuntu.com/ubuntu saucy main universe" > /etc/apt/sources.list
# Now, make sure the package repository is up to date
RUN apt-get update

RUN apt-get install -y openssh-server mongodb git screen supervisor

#create directory to get acme air
RUN useradd -m acme-air -p screencast -s /bin/bash
#RUN echo 'root:screencast' |chpasswd

EXPOSE 22
EXPOSE 27017

ADD supervisor.conf /etc/supervisor.conf
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor.conf" ]
