# in production this should probably be busybox, but let's use ubuntu for a
# fair comparison 
FROM tutum/ubuntu-saucy

MAINTAINER Ram Rajamony, rajamon@us.ibm.com

RUN apt-get install -y libgomp1
ADD bin bin/
CMD /bin/runme_xeon64
