#!/bin/bash

CUBE=controls.room-house.com
RESULT=`/usr/bin/curl --silent  --connect-timeout 2 https://$CUBE/cgi/genc/check`;

if [ $RESULT -eq 10 ]; then
	/sbin/init 6
fi
