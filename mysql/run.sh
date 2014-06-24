#!/bin/bash

runId=0
while [ $runId -lt 10 ]
do
				numCli=10
				while [ $numCli -lt 180 ]
				do
								sysbench --test=oltp --oltp-table-size=2000000 --mysql-db=test --mysql-host=arldcn24 --mysql-user=admin --mysql-port=3306 --mysql-password=supervisor --max-time=60 --oltp-read-only=on --max-requests=0 --num-threads=$numCli
 run
								sleep 5
								numCli=$(($numCli + 10))
				done > /tmp/results-2000000-docker-hostnet-hostfs$runId
				runId=$(($runId + 1))
done
