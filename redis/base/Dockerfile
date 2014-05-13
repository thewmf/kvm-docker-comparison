# In production this should probably be busybox, but let's use ubuntu for a
# fair comparison 
#
# Source: https://index.docker.io/u/tutum/ubuntu-saucy/
FROM tutum/ubuntu-saucy

MAINTAINER Juan Rubio, rubioj@us.ibm.com

# The apt sources config file contains:
#    deb http://archive.ubuntu.com/ubuntu saucy main universe
#    deb http://archive.ubuntu.com/ubuntu saucy-updates main universe
#    deb http://archive.ubuntu.com/ubuntu saucy-security main universe
# We want to be lean, and reduce build time, so remove most repositories
RUN sh -c 'cp -p /etc/apt/sources.list /etc/apt/sources.list.orig; echo "deb http://archive.ubuntu.com/ubuntu saucy main universe" > /etc/apt/sources.list'
# Now, make sure the package repository is up to date
RUN apt-get update

# Install a few packages we use
RUN apt-get install -y openssh-server screen supervisor git

# Change root password
RUN echo 'root:screencast'|chpasswd
