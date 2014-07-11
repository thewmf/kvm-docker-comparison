# In production this should probably be busybox, but let's use ubuntu for a
# fair comparison 
# docker run -d -p 3306:3306 -e MYSQL_PASS="password" tutum/mysql

FROM ubuntu:saucy 
MAINTAINER Alexandre Ferreira, apferrei@us.ibm.com

# Install packages
RUN apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install mysql-server net-tools

# Exposed ENV
ADD mysql-opt.cnf /etc/mysql/conf.d/mysql-opt.cnf
ADD install-mysql.sh /install-mysql.sh
ADD run.sh /run.sh

RUN rm -rf /var/lib/mysql/*

RUN /install-mysql.sh

# Add VOLUMEs to allow backup of config and databases

VOLUME  ["/home/mysql","/etc/mysql", "/var/lib/mysql"]
EXPOSE 3306
CMD ["/run.sh"]
