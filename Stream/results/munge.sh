#!/bin/bash

# This script processes the following log files and generates data suitable for pasting into stream.xlsx
# 
# docker.single-socket.localalloc.log
# docker.two-socket.interleavedalloc.log
# linux.single-socket.localalloc.log
# linux.two-socket.interleavedalloc.log
# vm.single-socket.localalloc.log
# vm.two-socket.interleavedalloc.log

egrep "^Copy:|^Scale:|^Add:|^Triad:" linux.single-socket.localalloc.log  | sed 's/://' | sort -k2n | awk -v caption=1 -f munge.awk > /tmp/linux.$$
egrep "^Copy:|^Scale:|^Add:|^Triad:" docker.single-socket.localalloc.log | sed 's/://' | sort -k2n | awk -f munge.awk > /tmp/docker.$$
egrep "^Copy:|^Scale:|^Add:|^Triad:" vm.single-socket.localalloc.log     | sed 's/://' | sort -k2n | awk -f munge.awk > /tmp/vm.$$

egrep "^Copy:|^Scale:|^Add:|^Triad:" linux.two-socket.interleavedalloc.log  | sed 's/://' | sort -k2n | awk -f munge.awk > /tmp/linux.two.$$
egrep "^Copy:|^Scale:|^Add:|^Triad:" docker.two-socket.interleavedalloc.log | sed 's/://' | sort -k2n | awk -f munge.awk > /tmp/docker.two.$$
egrep "^Copy:|^Scale:|^Add:|^Triad:" vm.two-socket.interleavedalloc.log     | sed 's/://' | sort -k2n | awk -f munge.awk > /tmp/vm.two.$$

paste /tmp/linux.$$ /tmp/docker.$$ /tmp/vm.$$ /tmp/linux.two.$$ /tmp/docker.two.$$ /tmp/vm.two.$$

rm -f /tmp/linux.$$ /tmp/docker.$$ /tmp/vm.$$ /tmp/linux.two.$$ /tmp/docker.two.$$ /tmp/vm.two.$$

