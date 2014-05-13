#!/bin/bash

cp settings.json settings.json.old
sed -e "s/127.0.0.1/$DB_PORT_27017_TCP_ADDR/" settings.json.old > settings.json
exec node app

