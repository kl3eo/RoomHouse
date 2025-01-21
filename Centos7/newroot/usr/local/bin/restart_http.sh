#!/bin/bash

echo ......
ret=`/usr/local/apache2/bin/apachectl restart`
echo $ret
sleep 2

E=`ps aux | grep httpd |  grep -v grep | grep Ss | awk '{print $2}'`

if [ -z $E ]; then
echo "Service HTTP(S) could not be restarted :("
else
echo "Service HTTP(S) successfully restarted!"
fi
