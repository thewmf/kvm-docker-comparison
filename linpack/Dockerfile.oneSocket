# in production this should probably be busybox, but let's use ubuntu for a
# fair comparison 
FROM tutum/ubuntu-saucy

MAINTAINER Ram Rajamony, rajamon@us.ibm.com

RUN apt-get -qq install -y libgomp1 numactl
ADD bin /
CMD numactl --physcpubind=0-7,16-23 --localalloc /runme_xeon64
