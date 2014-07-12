#!/bin/bash

checkIfMysqlRunning() {
while true
do
	echo "Checking if mysqld is running and available" 
	netstatRes=`netstat -an | grep 3306 | grep LISTEN` 
	if [ "x${netstatRes}x" != "xx" ]
	then	
		return;
	fi
	sleep 1
done
}

/usr/bin/mysql_install_db
/usr/bin/mysqld_safe&
checkIfMysqlRunning
mysql -uroot -h127.0.0.1 -e "CREATE USER 'root'@'%' IDENTIFIED BY 'supervisor'"
mysql -uroot -h127.0.0.1 -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION"
mysql -uroot -h127.0.0.1 -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'supervisor'"
mysql -uroot -h127.0.0.1 -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"
mysqladmin -uroot -h127.0.0.1 password 'supervisor' 
mysqladmin -uroot -psupervisor -h127.0.0.1 shutdown
