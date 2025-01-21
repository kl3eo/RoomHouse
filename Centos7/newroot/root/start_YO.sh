#!/bin/bash

if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
	echo "Interfaces description not found, exiting.."
	exit 1
fi

IP=/sbin/ip

$IP rule del from all fwmark 3 table TL

#$IP rule del from $TER table YOTA

if [ -f /etc/sysconfig/primary_host ]; then
	$IP rule del from $SEC table BEE
fi
$IP rule del from $PRI table GT


$IP rule add from $PRI table GT
if [ -f /etc/sysconfig/primary_host ]; then
	$IP rule add from $SEC table BEE
fi

#$IP rule add from $TER table YOTA
$IP rule add from all fwmark 3 table TL
