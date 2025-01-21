#!/bin/bash

echo ......
su - postgres -c "/usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data restart"
sleep 2

E=`ps aux | grep /usr/local/pgsql/bin/postgres |  grep -v grep | awk '{print $2}'`

if [ -z $E ]; then
echo "Service DB could not be restarted :("
else
echo "Service DB successfully restarted!"
fi
