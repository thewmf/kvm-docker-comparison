#!/bin/sh

############################################################
# Provisioning commands *after* containers have been created
############################################################


# Start the backend database for the workload
#sudo docker run -d -name mongodb crosbymichael/redis

# Start the 'empty' docker, with a new root password
docker run -d -p 0.0.0.0:2222:22 -e ROOT_PASS="screencast" --name empty1 empty

docker run -d -p 0.0.0.0:2223:22 -e ROOT_PASS="screencast" --name empty2 empty

docker run -d -p 0.0.0.0:2224:22 -e ROOT_PASS="screencast" --name mongo1 mongodb
