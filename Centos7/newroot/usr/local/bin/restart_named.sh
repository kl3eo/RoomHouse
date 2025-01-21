#!/bin/bash

echo ......
ret=`cat /var/named/chroot/var/run/named/named.pid`
kill -9 $ret
/usr/sbin/named -u named -c /etc/named.conf -t /var/named/chroot
sleep 2

E=`ps aux | grep /usr/sbin/named |  grep -v grep | grep Ss | awk '{print $2}'`

if [ -z $E ]; then
echo "Service DNS could not be restarted :("
else
echo "Service DNS successfully restarted!"
fi
