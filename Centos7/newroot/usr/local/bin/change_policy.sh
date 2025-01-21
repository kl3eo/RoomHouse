#!/bin/bash
if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
        echo "Interfaces description not found, exiting.."
        exit 1
fi

rm -f /etc/sysconfig/interfaces.saved
rm -f /etc/sysconfig/interfaces.new

if (( "$1" == 0 )) ; then
	rm -rf /root/iptables.sh
	ln -s /root/iptables_bl.sh /root/iptables.sh
	sed -i '/KEY3=/d' /etc/sysconfig/interfaces
	echo "KEY3=0" >> /etc/sysconfig/interfaces
	cp -a /etc/sysconfig/interfaces /etc/sysconfig/interfaces.new	
	/root/iptables.sh
elif (( "$1" == 1 )) ; then
	rm -rf /root/iptables.sh
	ln -s /root/iptables_wl.sh /root/iptables.sh
	sed -i '/KEY3=/d' /etc/sysconfig/interfaces
	echo "KEY3=1" >> /etc/sysconfig/interfaces
	cp -a /etc/sysconfig/interfaces /etc/sysconfig/interfaces.new
	/root/iptables.sh
elif (( "$1" == 2 )) ; then
	rm -rf /usr/local/apache2/conf/httpd.conf && ln -s /usr/local/apache2/conf/httpd.conf.https /usr/local/apache2/conf/httpd.conf && sed -i '/KEY4=/d' /etc/sysconfig/interfaces && echo "KEY4=1" >> /etc/sysconfig/interfaces && cp -a /etc/sysconfig/interfaces /etc/sysconfig/interfaces.new && /usr/local/apache2/bin/apachectl restart
elif (( "$1" == 3 )) ; then
	rm -rf /usr/local/apache2/conf/httpd.conf && ln -s /usr/local/apache2/conf/httpd.conf.http /usr/local/apache2/conf/httpd.conf && sed -i '/KEY4=/d' /etc/sysconfig/interfaces && echo "KEY4=0" >> /etc/sysconfig/interfaces && cp -a /etc/sysconfig/interfaces /etc/sysconfig/interfaces.new && /usr/local/apache2/bin/apachectl restart
else
echo "Other!"
exit
fi
