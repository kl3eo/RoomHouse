#!/bin/bash

if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
	echo "Interfaces description not found, exiting.."
	exit 1
fi

if [ -f /etc/sysconfig/primary_host ]; then

IPTABLES=/sbin/iptables
IP=/sbin/ip

#catching packets going to fictitious 172.16.0.1
$IPTABLES -A OUTPUT -p tcp -m tcp -d 172.16.0.1 -j MARK --set-mark 0x03 -t mangle

$IPTABLES -A PREROUTING -s $DEC_GW -i $DEC_IF -p tcp -m tcp --dport 3128 -d 172.16.0.1 -j REDIRECT --to-ports 3128 -t nat
$IPTABLES -A PREROUTING -s $DEC_GW -i $DEC_IF -p tcp -m tcp --dport 993 -d 172.16.0.1 -j REDIRECT --to-ports 993 -t nat
$IPTABLES -A PREROUTING -s $DEC_GW -i $DEC_IF -p tcp -m tcp --dport 25 -d 172.16.0.1 -j REDIRECT --to-ports 25 -t nat

# always sending packets to port 8085 throu SEC interaface if SCHEME ONE and "track_sec_channel.sh" is enabled, only
# and comment the following 3 lines if SCHEME TWO with "track_pri_channel.sh" is enabled

#$IPTABLES -A OUTPUT -s $PRI -p tcp -m tcp --dport 8085 -j MARK --set-mark 0x04 -t mangle
#$IPTABLES -A POSTROUTING -s $PRI -o $SEC_IF -p tcp -m tcp --dport 8085 -j SNAT --to-source $SEC -t nat
#$IP rule add from all fwmark 4 table BEE

fi
