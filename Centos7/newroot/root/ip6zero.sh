#!/bin/bash

if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
	echo "Interfaces description not found, exiting.."
	exit 1
fi

IP6TABLES="/sbin/ip6tables"

$IP6TABLES -F

$IP6TABLES -P INPUT ACCEPT
$IP6TABLES -P FORWARD ACCEPT
$IP6TABLES -P OUTPUT ACCEPT
