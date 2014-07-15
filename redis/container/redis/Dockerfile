# In production this should probably be busybox, but let's use ubuntu for a
# fair comparison 
FROM rubioj/base

MAINTAINER Juan Rubio, rubioj@us.ibm.com

# Install the redis server and CLI tool
#RUN apt-get install -y redis-server
ADD pack.tar.gz /tmp/

# We want to ensure there is a directory to run the redis-server, and that it has a sane password
RUN useradd -m redisuser -s /bin/bash
RUN echo 'redisuser:screencast'|chpasswd

EXPOSE 22
EXPOSE 6379

ADD supervisor.conf /etc/supervisor.conf
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisor.conf" ]
