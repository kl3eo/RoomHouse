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

$IP6TABLES -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

$IP6TABLES -A INPUT -p ipv6-icmp -j ACCEPT

$IP6TABLES -A INPUT -i lo -j ACCEPT
$IP6TABLES -A INPUT -i $PRI_IF -s fc00::/7 -j ACCEPT

$IP6TABLES -A INPUT -j REJECT --reject-with icmp6-adm-prohibited
$IP6TABLES -A FORWARD -j REJECT --reject-with icmp6-adm-prohibited
$IP6TABLES -A OUTPUT -j REJECT --reject-with icmp6-adm-prohibited
