#!/bin/sh

# Run Redis benchmark against redis1 container.
#    -q: quiet
#    -c: 250 clients
#    -t: benchmark 'ping', 'set' and 'get' (others ...)
#    -d: data is 100bytes
#    -r: keyspace of 10000 keys
#    -n: request 1000000 operations
docker run --name=redis-bench1 --link=redis1:db --rm=true -t -i redis \
    redis-benchmark -h db -q -c 250 -t ping,set,get -d 100 -r 10000 -n 1000000
