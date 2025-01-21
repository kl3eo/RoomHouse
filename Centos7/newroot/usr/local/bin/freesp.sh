#!/bin/bash

softpac=`cat /etc/sysconfig/softpac`

if [ ! -n "`mount | grep /opt/nvme`" ]; then
# if [ $softpac -eq 0 ]; then
	rm -f /opt/nvme/videos/*
#rm -rf /var/www/html/lightsquid/report/*
#fi
fi

rm -f /home/nobody/*.ffm
