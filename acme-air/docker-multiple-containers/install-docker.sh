#!/bin/sh

############################################################
# Provisioning commands *before* containers are created
############################################################


# We will likely need git, wget and curl
sudo apt-get -q -y install git
sudo apt-get -q -y install wget curl

# Add apt repository for docker
sudo sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
# Make sure the package repository is up to date
sudo apt-get -q -y update
# Install Docker (we don't have an MD5, so force the install)
sudo apt-get -q -y --force-yes install lxc-docker
# I would like to use docker without sudo
sudo chmod u+s /usr/bin/docker

