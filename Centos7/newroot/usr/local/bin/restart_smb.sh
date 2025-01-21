#!/bin/bash

echo ......
service smb restart
service nmb restart
sleep 2

E=`ps aux | grep /usr/sbin/smbd |  grep -v grep | grep Ss | awk '{print $2}'`
F=`ps aux | grep /usr/sbin/nmbd |  grep -v grep | grep Ss | awk '{print $2}'`

if [ -z $E ]; then
echo "Service FILE could not be restarted :("
elif [ -z $F ]; then
echo "Service FILE could not be restarted :("
else
echo "Service FILE successfully restarted!"
fi
