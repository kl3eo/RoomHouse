#!/bin/sh

if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
	echo "Interfaces description not found, exiting.."
	exit 1
fi

WLAN_DHCP=`echo $WLAN_IP | sed 's|\(.*\)\..*|\1|'`".0/24"

IPTABLES="/sbin/iptables"
IP6TABLES="/sbin/ip6tables"

echo 1 > /proc/sys/net/ipv4/ip_forward

######
#ipv6#
######
$IP6TABLES -F

$IP6TABLES -P INPUT ACCEPT
$IP6TABLES -P FORWARD ACCEPT
$IP6TABLES -P OUTPUT ACCEPT

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

# transparent proxy for wlan
$IPTABLES -t nat -A PREROUTING -i $WLAN_IF --match multiport -p tcp ! --dport 3128,443,22,587,993,4443,4477,5900,8080 -j REDIRECT --to-port 3128
$IPTABLES -t nat -A PREROUTING -i $WLAN_IF -p tcp --dport 443 -j REDIRECT --to-port 3129
$IPTABLES -t nat -A PREROUTING -i $WLAN_IF -p tcp --dport 4477 -j REDIRECT --to-port 3129

# transparent proxy for eth1
$IPTABLES -t nat -A PREROUTING -i $SEC_IF --match multiport -p tcp ! --dport 3128,443,22,587,993,4443,4477,5900,8080 -j REDIRECT --to-port 3128
$IPTABLES -t nat -A PREROUTING -i $SEC_IF -p tcp --dport 443 -j REDIRECT --to-port 3129
$IPTABLES -t nat -A PREROUTING -i $SEC_IF -p tcp --dport 4477 -j REDIRECT --to-port 3129

# Masquerade traffic from wlan (as it kills filtering results, so we dont use it), except DNS to google, xETR mail
$IPTABLES -t nat -A POSTROUTING -o $PRI_IF -s $WLAN_DHCP -p udp -d 8.8.0.0/16 --dport 53 -j MASQUERADE
$IPTABLES -t nat -A POSTROUTING -o $PRI_IF -s $WLAN_DHCP -p tcp -d 8.8.0.0/16 --dport 53 -j MASQUERADE

# Masquerade traffic from eth1 (as it kills filtering results, so we dont use it), except DNS to google, xETR mail
$IPTABLES -t nat -A POSTROUTING -o $PRI_IF -s $SEC_NET -p udp -d 8.8.0.0/16 --dport 53 -j MASQUERADE
$IPTABLES -t nat -A POSTROUTING -o $PRI_IF -s $SEC_NET -p tcp -d 8.8.0.0/16 --dport 53 -j MASQUERADE

$IPTABLES -t nat -I PREROUTING -i $PRI_IF -p tcp -m tcp -d $PRI --dport 443 -j REDIRECT --to-port 8443
#$IPTABLES -t nat -I PREROUTING -i $PRI_IF -p tcp -m tcp -d $PRI --dport 8443 -j REDIRECT --to-port 443
$IPTABLES -t nat -I PREROUTING -i $PRI_IF -p tcp -m tcp -d $PRI --dport 8453 -j REDIRECT --to-port 443

echo "nat ok"

###############
#FILTER SECTION
###############

### 1: Drop invalid packets ### 
# -- not good for VirtualBox --ash
#$IPTABLES -t mangle -A PREROUTING -m conntrack --ctstate INVALID -j DROP  

### 2: Drop TCP packets that are new and are not SYN ### 
$IPTABLES -t mangle -A PREROUTING -p tcp ! --syn -m conntrack --ctstate NEW -j DROP 
 
### 3: Drop SYN packets with suspicious MSS value ### 
$IPTABLES -t mangle -A PREROUTING -p tcp -m conntrack --ctstate NEW -m tcpmss ! --mss 536:65535 -j DROP  

### 4: Block packets with bogus TCP flags ### 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP 
$IPTABLES -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP  

### 5: Block spoofed packets ### 
$IPTABLES -t mangle -A PREROUTING -s 224.0.0.0/3 -j DROP 
$IPTABLES -t mangle -A PREROUTING -s 169.254.0.0/16 -j DROP 
$IPTABLES -t mangle -A PREROUTING -s 172.16.0.0/12 -j DROP 
#$IPTABLES -t mangle -A PREROUTING -s 192.0.2.0/24 -j DROP 
$IPTABLES -t mangle -A PREROUTING -s 0.0.0.0/8 -j DROP 
$IPTABLES -t mangle -A PREROUTING -s 240.0.0.0/5 -j DROP 
$IPTABLES -t mangle -A PREROUTING -s 127.0.0.0/8 ! -i lo -j DROP  

### 6: Drop ICMP (you usually don't need this protocol) ### 
$IPTABLES -t mangle -A PREROUTING -p icmp -j DROP  

### 7: Drop fragments in all chains ### 
$IPTABLES -t mangle -A PREROUTING -f -j DROP  

### 8: Limit connections per source IP ### 
$IPTABLES -A INPUT -p tcp -m connlimit --connlimit-above 512 -j REJECT --reject-with tcp-reset  

#qos ddos reco
$IPTABLES -A INPUT -p tcp --match multiport --dports 80,443,8443,8467 -m state --state NEW -m limit --limit 60/minute --limit-burst 250 -j ACCEPT

# limits the number of established/concurrent connections:
$IPTABLES -A INPUT -p tcp --match multiport --dports 80,443,8443,8467 -m state --state RELATED,ESTABLISHED -m limit --limit 50/second --limit-burst 50 -j ACCEPT

# limits the connections from a single source IP to 50:
$IPTABLES -A INPUT -p tcp --syn --match multiport --dports 80,443,8443,8467 -m connlimit --connlimit-above 50 -j REJECT

### 9: Limit RST packets ### 
$IPTABLES -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT 
$IPTABLES -A INPUT -p tcp --tcp-flags RST RST -j DROP  

### 10: Limit new TCP connections per second per source IP ### 
$IPTABLES -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 360/s --limit-burst 120 -j ACCEPT 
$IPTABLES -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP  
#####

$IPTABLES -P INPUT DROP
$IPTABLES -P OUTPUT DROP
$IPTABLES -P FORWARD DROP

$IPTABLES -N firewall
$IPTABLES -A firewall -m limit --limit 15/minute -j LOG --log-prefix Firewall:
$IPTABLES -A firewall -j DROP

$IPTABLES -N dropwall
$IPTABLES -A dropwall -m limit --limit 15/minute -j LOG --log-prefix Dropwall:
$IPTABLES -A dropwall -j DROP

$IPTABLES -N badflags
$IPTABLES -A badflags -m limit --limit 15/minute -j LOG --log-prefix Badflags:
$IPTABLES -A badflags -j DROP

$IPTABLES -N silent
$IPTABLES -A silent -j DROP

#letting in all LAN
$IPTABLES -A INPUT -i lo -j ACCEPT
$IPTABLES -A INPUT -s $PRI_NET -i $PRI_IF -j ACCEPT
$IPTABLES -A INPUT -i $TUN_IF -j ACCEPT
$IPTABLES -A INPUT -i $WLAN_IF -j ACCEPT
$IPTABLES -A INPUT -i $SEC_IF -j ACCEPT

#purging bad stuff
$IPTABLES -A INPUT -p tcp --tcp-flags ALL FIN,URG,PSH -j badflags
$IPTABLES -A INPUT -p tcp --tcp-flags ALL ALL -j badflags
$IPTABLES -A INPUT -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j badflags
$IPTABLES -A INPUT -p tcp --tcp-flags ALL NONE -j badflags
$IPTABLES -A INPUT -p tcp --tcp-flags SYN,RST SYN,RST -j badflags
$IPTABLES -A INPUT -p tcp --tcp-flags SYN,FIN SYN,FIN -j badflags

$IPTABLES -A INPUT -p icmp --icmp-type 0 -j ACCEPT
$IPTABLES -A INPUT -p icmp --icmp-type 3 -j ACCEPT
$IPTABLES -A INPUT -p icmp --icmp-type 11 -j ACCEPT
$IPTABLES -A INPUT -p icmp --icmp-type 8 -m limit --limit 1/second -j ACCEPT
$IPTABLES -A INPUT -p icmp -j firewall

#letting in return packets
$IPTABLES -A INPUT -d $PRI -i $PRI_IF -m state --state RELATED,ESTABLISHED -j ACCEPT

#for PRI:
#ssh
$IPTABLES -A INPUT -s 81.25.50.12 -p tcp -m tcp --dport 22 -j ACCEPT
$IPTABLES -A INPUT -d $PRI -s 91.188.188.198 -p tcp -m tcp --dport 22 -j ACCEPT
$IPTABLES -A INPUT -d $PRI -s 95.141.185.227 -p tcp -m tcp --dport 22 -j ACCEPT

#http(s)
$IPTABLES -A INPUT -d $PRI -p tcp -m tcp --dport 80 -j ACCEPT
$IPTABLES -A INPUT -d $PRI -p tcp -m tcp --dport 443 -j ACCEPT
$IPTABLES -A INPUT -d $PRI -p tcp -m tcp --dport 8079 -j ACCEPT
$IPTABLES -A INPUT -d $PRI -p tcp -m tcp --dport 8443 -j ACCEPT
#apache proxy of kurento's 8888
$IPTABLES -A INPUT -d $PRI -p tcp -m tcp --dport 8467 -j ACCEPT

#postgres
#$IPTABLES -A INPUT -d $PRI -s 95.141.185.227 -p tcp -m tcp --dport 5432 -j ACCEPT

#ETH squid
$IPTABLES -A INPUT -d $SEC -p tcp -m tcp -s $SEC_NET --dport 8080 -j ACCEPT

#coturn
$IPTABLES -A INPUT -d $PRI -p tcp -m tcp --dport 3478 -j ACCEPT
$IPTABLES -A INPUT -d $PRI -p udp -m udp --dport 3478 -j ACCEPT
# -- this is needed for Kurento, too, and much lower than 49152, setting 1025 --ash
$IPTABLES -A INPUT -p udp --match multiport --dports 1025:65535 -j ACCEPT

#kurento
$IPTABLES -A INPUT -d 127.0.0.1 -p tcp -m tcp --dport 8888 -j ACCEPT

#openvpn 

$IPTABLES -A INPUT -i $PRI -p udp -m udp --dport 1194 -j ACCEPT

#drop netbios
$IPTABLES -A INPUT -p udp --sport 137 --dport 137 -j silent

#bad guys
#$IPTABLES -A INPUT -s 62.210.139.74 -j DROP

# drop all the rest

$IPTABLES -A INPUT -j silent

echo "filter ok"

# Allow traffic initiated from WLAN and SEC

$IPTABLES -A FORWARD -i $WLAN_IF -o $PRI_IF -j ACCEPT
$IPTABLES -A FORWARD -i $PRI_IF -o $WLAN_IF -j ACCEPT

$IPTABLES -A FORWARD -i $SEC_IF -o $PRI_IF -j ACCEPT
$IPTABLES -A FORWARD -i $PRI_IF -o $SEC_IF -j ACCEPT

$IPTABLES -A FORWARD -i $SEC_IF -o $WLAN_IF -j ACCEPT
$IPTABLES -A FORWARD -i $WLAN_IF -o $SEC_IF -j ACCEPT

#QUIC stuff blocker -- https://wiki.squid-cache.org/KnowledgeBase/Block%20QUIC%20protocol

#$IPTABLES -A FORWARD -i $PRI_IF -p udp -m udp --dport 80 -j REJECT --reject-with icmp-port-unreachable
#$IPTABLES -A FORWARD -i $PRI_IF -p udp -m udp --dport 443 -j REJECT --reject-with icmp-port-unreachable

#$IPTABLES -A FORWARD -p tcp -m tcp --dport 80 -m state --state NEW,RELATED,ESTABLISHED -j DROP
#$IPTABLES -A FORWARD -p tcp -m tcp --dport 443 -m state --state NEW,RELATED,ESTABLISHED -j DROP

$IPTABLES -A FORWARD -j dropwall

echo "forward ok"

#script
SOFTPAC=`cat /etc/sysconfig/softpac`
if [[ $SOFTPAC -ne 7 ]]; then
/usr/local/bin/read_bl.pl
fi

$IPTABLES -A INPUT -s 127.0.0.1 -p tcp -m tcp --dport 8888 -j ACCEPT
$IPTABLES -A INPUT -p tcp -m tcp --dport 8888 -j DROP

$IPTABLES -A OUTPUT -d 127.0.0.1 -p tcp -m tcp --sport 8888 -j ACCEPT
$IPTABLES -A OUTPUT -p tcp -m tcp --sport 8888 -j DROP

$IPTABLES -A OUTPUT -o lo -j ACCEPT 
$IPTABLES -A OUTPUT -o $TUN_IF -j ACCEPT
$IPTABLES -A OUTPUT -o $WLAN_IF -j ACCEPT
$IPTABLES -A OUTPUT -o $SEC_IF -j ACCEPT

$IPTABLES -A OUTPUT -s $PRI -o $PRI_IF -j ACCEPT

$IPTABLES -A OUTPUT -j dropwall  

echo "output ok"

######
#ipv6#
######

$IP6TABLES -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

$IP6TABLES -A INPUT -p ipv6-icmp -j ACCEPT

$IP6TABLES -A INPUT -i lo -j ACCEPT
$IP6TABLES -A OUTPUT -o lo -j ACCEPT
$IP6TABLES -A INPUT -i $WLAN_IF -j ACCEPT
$IP6TABLES -A OUTPUT -o $WLAN_IF -j ACCEPT
$IP6TABLES -A INPUT -i $SEC_IF -j ACCEPT
$IP6TABLES -A OUTPUT -o $SEC_IF -j ACCEPT
$IP6TABLES -A INPUT -i $PRI_IF -s fc00::/7 -j ACCEPT
$IP6TABLES -A OUTPUT -o $PRI_IF -d fc00::/7 -j ACCEPT

$IP6TABLES -A INPUT -j REJECT --reject-with icmp6-adm-prohibited
$IP6TABLES -A FORWARD -j REJECT --reject-with icmp6-adm-prohibited
$IP6TABLES -A OUTPUT -j REJECT --reject-with icmp6-adm-prohibited

echo "ipv6 ok"

exit 0;
