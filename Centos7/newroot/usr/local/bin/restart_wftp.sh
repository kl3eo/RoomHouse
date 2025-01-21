#!/bin/bash

echo ......

E=`ps aux | grep ./wftpserver |  grep -v grep | awk '{print $2}'`

if [ -z $E ]; then
	if [ -b /dev/nvme0n1p1 ]; then	
		mount /dev/nvme0n1p1 /var/wftpserver/opt
		chroot /var/wftpserver ./startwftp.sh 
	fi
else 
	killall wftpserver
fi

sleep 10

E=`ps aux | grep ./wftpserver |  grep -v grep | awk '{print $2}'`

if [ -z $E ]; then
	echo "Service FTP stopped"
else
	echo "Service FTP successfully started!"
fi
