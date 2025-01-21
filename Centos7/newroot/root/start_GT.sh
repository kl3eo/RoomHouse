
#!/bin/bash

if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
	echo "Interfaces description not found, exiting.."
	exit 1
fi

IP=/sbin/ip
ROUTE=/sbin/route

SOFTPAC=`cat /etc/sysconfig/softpac`

/sbin/ifconfig $PRI_IF hw ether $PRI_MAC
/sbin/ifconfig $PRI_IF inet $PRI
$IP route add $PRI_NET dev $PRI_IF src $PRI

$ROUTE add default $PRI_IF
$ROUTE add default gw $PRI_GW

modprobe ax88179_178a
modprobe r8152

sleep 2

/sbin/ifconfig $SEC_IF inet $SEC
$IP route add $SEC_NET dev $SEC_IF src $SEC

/bin/hostname $HOSTNAME

SEC_SMB=`echo $SEC | sed 's|\(.*\)\..*|\1|'`
SQUID_FADDR=$SEC_SMB".222"

if [[ $SOFTPAC -ne 7 ]]; then
/sbin/ifconfig $PRI_IF:1 inet $SQUID_FADDR
fi

if [[ $KEY6 == "true" ]] ; then
        /sbin/dhclient $PRI_IF
fi
