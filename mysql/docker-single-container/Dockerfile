# In production this should probably be busybox, but let's use ubuntu for a
# fair comparison 
# docker run -d -p 3306:3306 -e MYSQL_PASS="password" tutum/mysql

FROM tutum/mysql

MAINTAINER Alexandre Ferreira, apferrei@us.ibm.com

ADD mysql-opt.cnf /etc/mysql/conf.d/mysql-opt.cnf
