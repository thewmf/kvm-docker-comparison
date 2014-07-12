#!/bin/bash

DATABASDIR=/home/mysql

NFILES=`ls -l $DATABASEDIR/ibdata* 2>/dev/null | wc -l` 

checkIfMysqldIsRunning() {
while true
do
	echo "Checking if mysqld is running and available" 
	nProc=`ps -ef | grep mysqld | grep -v grep | wc -l` 
	if [ $nProc -lt 1 ]
	then	
		return;
	fi
	sleep 1
done
}

if [ $NFILES -lt 1 ]
then
	./install-mysql.sh
	checkIfMysqldIsRunning
fi
exec /usr/bin/mysqld_safe
