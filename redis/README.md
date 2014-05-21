Redis
=====

This directory creates containers to run the Redis
benchmark.[redis]

Building the container
----------------------

Run ```build-docker-images.sh``` to build the image
for the container.
You will end up with 2 Docker images tagged as *base* and *redis*.

The *base* container is just:

* an Ubuntu (13.04 Saucy) container,
* plus ssh, screen and supervisor

The *redis* container:
* *base* conainer,
* plus redis-server.

Benchmarking
----------------------

* Run ```redis-start.sh```, to start a fresh container running the redis server.
* Run ```redis-benchmark.sh```, to run the test agains the redis server you just started.  Once the test ends, this container stops.
* Run ```redis-stop.sh```, to stop the redis server you started initially.


Sources
-------


* [redis]: http://redis.io/topics/benchmarks
