# In production this should probably be busybox, but let's use ubuntu for a
# fair comparison 
#
# Source: https://index.docker.io/u/tutum/ubuntu-saucy/
FROM tutum/ubuntu-saucy

MAINTAINER Juan Rubio, rubioj@us.ibm.com

# We want to be lean, so remove most repositories
RUN sh -c 'mv /etc/apt/sources.list /etc/apt/sources.list.orig; echo "deb http://archive.ubuntu.com/ubuntu saucy main universe" > /etc/apt/sources.list'
# Make sure the package repository is up to date
RUN apt-get update

# Make sure the package repository is up to date
RUN apt-get install -y openssh-server screen supervisor

# Change root password
#RUN echo 'root:screencast' |chpasswd
