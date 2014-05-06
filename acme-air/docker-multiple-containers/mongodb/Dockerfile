# In production this should probably be busybox, but let's use ubuntu for a
# fair comparison 
FROM tutum/ubuntu-saucy

MAINTAINER Wes Felter, wmf@us.ibm.com

# make sure the package repository is up to date
#RUN echo "deb http://archive.ubuntu.com/ubuntu saucy main universe" > /etc/apt/sources.list
RUN apt-get update

RUN apt-get install -y openssh-server mongodb git screen supervisor

#create directory to get acme air
RUN useradd -m acme-air -s /bin/bash
RUN echo 'root:screencast' |chpasswd
RUN echo 'acme-air:screencast' |chpasswd

EXPOSE 3000
EXPOSE 22

ADD supervisor.conf /etc/supervisor.conf
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor.conf" ]
