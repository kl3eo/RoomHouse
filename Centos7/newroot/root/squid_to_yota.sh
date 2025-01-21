#!/bin/bash
if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
        echo "Interfaces description not found, exiting.."
        exit 1
fi

PRI_SMB=`echo $PRI | sed 's|\(.*\)\..*|\1|'`
SEC_SMB=`echo $SEC | sed 's|\(.*\)\..*|\1|'`
WLAN_DHCP=`echo $WLAN_IP | sed 's|\(.*\)\..*|\1|'`
SQUID_FADDR=$SEC_SMB".222"
SEC_ALL=$SEC_SMB".0"

sed -i "s/192.168.0.102/$PRI/g" /etc/hosts
sed -i "s/corfu/$HOSTNAME/g" /etc/hosts

sed -i "s/192.168.0.102/$PRI/g" /etc/resolv.conf

sed -i "s/192.168.0.102/$PRI/g" /var/named/chroot/etc/named.conf
sed -i "s/192.168.0/$PRI_SMB/g" /var/named/chroot/etc/named.conf

sed -i "s/192.168.0.102/$SEC/g" /etc/samba/smb.conf
sed -i "s/192.168.0/$SEC_SMB/g" /etc/samba/smb.conf

sed -i "s/192.168.56.254/$WLAN_IP/g" /etc/squid/squid.conf
sed -i "s/192.168.56/$WLAN_DHCP/g" /etc/squid/squid.conf
sed -i "s/192.168.88.253/$SQUID_FADDR/g" /etc/squid/squid.conf
sed -i "s/192.168.88.253/$SQUID_FADDR/g" /etc/squid/squid2.conf
sed -i "s/192.168.0.0/$SEC_ALL/g" /etc/squid/squid2.conf

#in check_office.sh
#sed -i '/stunServerAddress=/d' /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini && echo stunServerAddress=$TURNSERVER >> /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini
#sed -i '/turnURL=/d' /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini && echo turnURL=alex:shit\@$TURNSERVER:3478 >> /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini

sed -i "s/192.168.0.102/$PRI/g" /usr/local/apache2/conf/httpd.conf.http
sed -i "s/mydomain.lan/$DOM/g" /usr/local/apache2/conf/httpd.conf.http
sed -i "s/192.168.88.102/$SEC/g" /usr/local/apache2/conf/httpd.conf.http
sed -i "s/corfu/$HOSTNAME/g" /usr/local/apache2/conf/httpd.conf.http

sed -i "s/192.168.0.102/$PRI/g" /usr/local/apache2/conf/httpd.conf.https
sed -i "s/mydomain.lan/$DOM/g" /usr/local/apache2/conf/httpd.conf.https
sed -i "s/192.168.88.102/$SEC/g" /usr/local/apache2/conf/httpd.conf.https
sed -i "s/corfu/$HOSTNAME/g" /usr/local/apache2/conf/httpd.conf.https

sed -i "s/192.168.0.102/$PRI/g" /var/www/html/cp/handlers/genc/cp
sed -i "s/91.188.188.198/$EXT/g" /var/www/html/cp/handlers/genc/cp

sed -i "s/192.168.56/$WLAN_DHCP/g" /etc/dhcp/dhcpd.conf

sed -i "s/192.168.88/$SEC_SMB/g" /etc/dhcp/dhcpd.conf

sed -i "s/ssid=cordoba/ssid=$SSID/g" /etc/hostapd/hostapd.conf
WIFIPASS=`/usr/local/bin/chip8.sh $KEY1`
sed -i "s/wpa_passphrase=como_esta_usted/wpa_passphrase=$WIFIPASS/g" /etc/hostapd/hostapd.conf

sed -i "s/sleep 12/sleep $SRC_DELAY/g" /usr/local/bin/start_OD1.sh
sed -i "s/sleep 12/sleep $SRC_DELAY/g" /usr/local/bin/start_OD2.sh

XETR_PASSWD=`/usr/local/bin/chip8.sh $KEY2`
/var/www/html/cp/controls/removeUser.pl admin && /var/www/html/cp/controls/addUser.pl admin $XETR_PASSWD a\@b.com

if (( "$KEY3" == 0 )) ; then
	rm -rf /root/iptables.sh
	ln -s /root/iptables_bl.sh /root/iptables.sh
elif (( "$KEY3" == 1 )) ; then
	rm -rf /root/iptables.sh
	ln -s /root/iptables_wl.sh /root/iptables.sh
else
echo "Other!"
fi

if (( "$KEY4" == 0 )) ; then
	rm -rf /usr/local/apache2/conf/httpd.conf
	ln -s /usr/local/apache2/conf/httpd.conf.http /usr/local/apache2/conf/httpd.conf
elif (( "$KEY4" == 1 )) ; then
	rm -rf /usr/local/apache2/conf/httpd.conf
	ln -s /usr/local/apache2/conf/httpd.conf.https /usr/local/apache2/conf/httpd.conf

else
echo "Other!"
fi


if (( "$KEY5" == 1 )) ; then
	echo "good" > /root/good_job
else
#disabling office pack daemons

	ret=`cat /var/run/squid2.pid`
	kill -9 $ret
	/bin/systemctl stop smb
	/bin/systemctl stop nmb
	/bin/systemctl stop cyrus-imapd
	
	rm -rf /usr/sbin/nmbd.orig && mv /usr/sbin/nmbd  /usr/sbin/nmbd.orig
	rm -rf /usr/sbin/smbd.orig && mv /usr/sbin/smbd  /usr/sbin/smbd.orig
	rm -rf /usr/lib/cyrus-imapd/cyrus-master.orig && mv /usr/lib/cyrus-imapd/cyrus-master /usr/lib/cyrus-imapd/cyrus-master.orig
	rm -rf /etc/squid/squid2.conf.orig && mv /etc/squid/squid2.conf /etc/squid/squid2.conf.orig
fi

if [[ $KEY6 == "true" && $EXT == $PRI ]] ; then
	/sbin/dhclient eth0
fi

/root/start_GT.sh
