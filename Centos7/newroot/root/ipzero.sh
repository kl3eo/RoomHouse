#!/bin/sh

IPTABLES="/sbin/iptables"
PRI=`/bin/hostname -i`

PRI_IF=`/sbin/ip addr show | awk '/inet.*brd/{print $NF; exit}'`

echo 1 > /proc/sys/net/ipv4/ip_forward

######
#FLUSH
######

$IPTABLES -F
$IPTABLES -F INPUT
$IPTABLES -F OUTPUT
$IPTABLES -F FORWARD
$IPTABLES -F -t mangle
$IPTABLES -F -t nat
$IPTABLES -X

############
#NAT SECTION
############
$IPTABLES -t nat -P OUTPUT ACCEPT
$IPTABLES -t nat -P POSTROUTING ACCEPT
$IPTABLES -t nat -P PREROUTING ACCEPT

echo "nat ok"

###############
#FILTER SECTION
###############

$IPTABLES -P OUTPUT ACCEPT
$IPTABLES -P INPUT ACCEPT
$IPTABLES -P FORWARD ACCEPT

echo "FILTER ok"


exit 0;
