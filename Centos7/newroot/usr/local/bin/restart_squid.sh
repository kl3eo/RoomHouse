#!/bin/bash

if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
        echo "Interfaces description not found, exiting.."
        exit 1
fi

echo ......

if (( "$KEY5" == 1 )); then

	E=`ps aux | grep "usr/sbin/squid" |  grep -v squid2 | grep -v grep | awk '{print $2}'`
	F=`ps aux | grep "usr/sbin/squid" |  grep squid2 | grep -v grep | awk '{print $2}'`

	if [[ -z $E && -z $F ]]; then
		service squid start
		/usr/sbin/squid -f /etc/squid/squid2.conf
	elif [ -z $F ]; then
		/usr/sbin/squid -f /etc/squid/squid2.conf
	elif [ -z $E ]; then
		service squid start
	else 
		service squid stop
		ret=`cat /var/run/squid2.pid`
		kill -9 $ret && sleep 2		
	fi
else

	E=`ps aux | grep "usr/sbin/squid" |  grep -v squid2 | grep -v grep | awk '{print $2}'`
	if [ -z $E ]; then
		service squid start
	else 
		service squid stop
	fi

fi


if (( "$KEY5" == 1 )); then

	E=`ps aux | grep "usr/sbin/squid" |  grep -v squid2 | grep -v grep | awk '{print $2}'`
	F=`ps aux | grep "usr/sbin/squid" |  grep squid2 | grep -v grep | awk '{print $2}'`
	
	if [[ -z $E && -z $F ]]; then
		echo "Service Proxy-1 stopped"
		echo "Service Proxy-2 stopped"
	elif [ -z $E ]; then
		echo "Service Proxy-1 stopped"
	elif [ -z $F ]; then
		echo "Service Proxy-2 stopped"
	else 
		echo "Services Proxy-1/2 successfully started!"
	fi

else

	E=`ps aux | grep "usr/sbin/squid" |  grep -v squid2 | grep -v grep | awk '{print $2}'`

	if [ -z $E ]; then
		echo "Service Proxy-1 stopped"
	else 
		echo "Services Proxy-1 successfully started!"
	fi

fi
