#!/bin/bash

echo ......

E=`ps aux | grep sendmail |  grep -v grep | grep accepting | awk '{print $2}'`

if [ -z $E ]; then
	service sendmail start
else 
	service sendmail stop
fi

sleep 2

E=`ps aux | grep sendmail |  grep -v grep | grep accepting | awk '{print $2}'`

if [ -z $E ]; then
	echo "Service SMTP stopped"
else 
	echo "Service SMTP successfully started!"
fi
