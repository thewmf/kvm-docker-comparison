#!/bin/sh

docker build -t base           base
docker build -t nodejs         nodejs
docker build -t acmeair-nodejs acmeair-nodejs
docker build -t mongodb        mongodb
