#!/bin/bash
if [ -f /etc/sysconfig/interfaces.new ]; then
    . /etc/sysconfig/interfaces.new
else
        echo "Interfaces description not found, exiting.."
        exit 1
fi

ADDR=`cat /etc/sysconfig/interfaces.new | grep MAIL | awk -F '=' '{print $2}'`
TIME=`date`

if [ $1 -eq 1 ]; then
	echo "OBJECT $2 appeared at $TIME" | mail -s "$HOST: object $2 appeared" -r "alex@motivation.ru" "$ADDR"
elif [ $1 -eq 2 ]; then

	echo "OBJECT $2 disappeared at $TIME" | mail -s "$HOST: object $2 disappeared" -r "alex@motivation.ru" "$ADDR"
fi
