#!/bin/bash
. /etc/sysconfig/interfaces

WLAN_DHCP=`echo $WLAN_IP | sed 's|\(.*\)\..*|\1|'`
WLAN_NET=$WLAN_DHCP".0/24"

iptables -I INPUT -s $PRI_NET -d $PRI -p tcp -m tcp --dport 22 -j ACCEPT
iptables -t nat -A PREROUTING -p tcp --dport 8081 -j DNAT --to 192.168.88.99:8080
iptables -t nat -A PREROUTING -p tcp --dport 9656 -j DNAT --to 192.168.88.101:9656
iptables -t nat -A POSTROUTING -o $PRI_IF -s $SEC_NET -j MASQUERADE
iptables -t nat -A POSTROUTING -o $PRI_IF -s $WLAN_NET -j MASQUERADE
iptables -t nat -A POSTROUTING -o $PRI_IF -s 192.168.56.0/24 -j MASQUERADE
iptables -I INPUT -d $PRI -s 92.63.97.49 -p tcp -m tcp --dport 5432 -j ACCEPT
iptables -I INPUT -d $PRI -s $PRI_NET -p tcp -m tcp --dport 5432 -j ACCEPT

#iptables -I INPUT -d 81.25.50.12 -p tcp -m tcp --dport 5000 -j ACCEPT
#iptables -I INPUT -d 81.25.50.12 -p tcp -m tcp --dport 8081 -j ACCEPT

#iptables -A FORWARD -i docker0 -o eth0 -j ACCEPT
#iptables -A FORWARD -i eth0 -o docker0 -j ACCEPT


#!!!!!!!!!!!!!!!!!!1
#unblock PORT 8081 for local squid!!!!
