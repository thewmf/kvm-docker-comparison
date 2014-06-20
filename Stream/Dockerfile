# in production this should probably be busybox, but let's use ubuntu for a
# fair comparison 
FROM tutum/ubuntu-saucy

MAINTAINER Ram Rajamony, rajamon@us.ibm.com

RUN apt-get -qq install -y libgomp1
ADD bin /

# TODO: cat RESULTS so we can actually see it
CMD /stream.exe
