#!/bin/bash

echo ......

E=`ps aux | grep cyrus-master |  grep -v grep | grep Ss | awk '{print $2}'`

if [ -z $E ]; then
	service cyrus-imapd start
else 
	service cyrus-imapd stop
fi

sleep 2

E=`ps aux | grep cyrus-master |  grep -v grep | grep Ss | awk '{print $2}'`

if [ -z $E ]; then

echo "Service IMAP stopped"
else
echo "Service IMAP successfully started!"
fi
