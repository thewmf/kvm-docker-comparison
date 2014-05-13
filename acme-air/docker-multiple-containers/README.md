ACME-Air
========

This directory creates containers to run the ACME-Air
workload.[acmeair]

It is structured around 2 containers, one for the
datastore (MongoDB), and one for the application logic
(NodeJS).  We use a hierarchical approach to build the
containers.

Setting up the environment
--------------------------

Just run ```pre-docker.sh``` to install Docker in your
system.

Building the containers
-----------------------

Run ```build-docker-images.sh``` to build the images
for the containers.
You will end up with 4 Docker images.

The base container is *base*, which is just:

* an Ubuntu (13.04 Saucy) container,
* plus ssh, screen and supervisor.

From that container, we build *nodejs*, which is :

* base,
* plus nodejs and npm

Next is *acmeair-nodejs*:

* nodejs,
* plus git,
* plus acme-air code

The datastore is *mongodb*

* nodejs,
* plus mogodb

The last container also inclues the data used in the Acme-Air benchmark, *acmeair-mongodb*:

* mongodb,
* plus acme-air data


Sources
-------


* [acmeair]: https://github.com/acmeair/acmeair "acmeair github repository"
