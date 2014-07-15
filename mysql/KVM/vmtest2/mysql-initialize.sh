DEBIAN_FRONTEND=noninteractive sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt-get -y install mysql-server net-tools < /dev/null
DATABASEDIR=/var/lib/mysql

checkIfMysqlRunning() {
while true
do
	echo "Checking if mysqld is available" 
	netstatRes=`netstat -an | grep 3306 | grep LISTEN` 
	if [ "x${netstatRes}x" != "xx" ]
	then	
		return;
	fi
	sleep 1
done
}
checkIfMysqldIsRunning() {
while true
do
	echo "Checking if mysqld is running" 
	nProc=`ps -ef | grep mysqld | grep -v grep | wc -l`
	if [ $nProc -lt 1 ]
	then	
		return;
	fi
	sleep 1
done
}

sudo service mysql stop
sudo cp mysql-opt.cnf /etc/mysql/conf.d
checkIfMysqldIsRunning

NFILES=`ls -l $DATABASEDIR/ibdata* 2>/dev/null | wc -l` 
if [ $NFILES -gt 0 ]
then
	rm -rf $DATABASEDIR/*
fi

sudo /usr/bin/mysql_install_db
sudo /usr/bin/mysqld_safe&
checkIfMysqlRunning
echo "Starting creating the users" 
mysql -uroot -h127.0.0.1 -e "CREATE USER 'root'@'%' IDENTIFIED BY 'supervisor'"
mysql -uroot -h127.0.0.1 -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION"
mysql -uroot -h127.0.0.1 -e "CREATE USER 'admin'@'%' IDENTIFIED BY 'supervisor'"
mysql -uroot -h127.0.0.1 -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"
mysqladmin -uroot -h127.0.0.1 password 'supervisor' 
echo "Finished creating the users" 

exit
