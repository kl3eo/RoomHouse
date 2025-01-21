#!/bin/bash
/usr/bin/touch /var/log/streaming.log && /usr/bin/chown nobody /var/log/streaming.log
rm -f /etc/sysconfig/interfaces.new
if [ -f /etc/sysconfig/interfaces.saved ]; then
	cp -a /etc/sysconfig/interfaces.saved /etc/sysconfig/interfaces.new
elif [ -f /etc/sysconfig/interfaces ]; then
        cp -a /etc/sysconfig/interfaces /etc/sysconfig/interfaces.new
fi
