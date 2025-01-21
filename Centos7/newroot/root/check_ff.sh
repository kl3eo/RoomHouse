#!/bin/bash

CUBE=cube.xter.tech
RESULT=`/usr/bin/curl --silent  --connect-timeout 2 https://$CUBE/cgi/genc/check`;

if [ ${#RESULT} -eq 0 ]; then
        CUBE=aspen.room-house.com:8448
	RESULT=`/usr/bin/curl --silent  --connect-timeout 2 https://$CUBE/cgi/genc/check`;
fi

if [ $RESULT -ne 1 ]; then
	CUBE=cube.xter.tech
fi

echo Install ff:


if [ ! -f /opt/nvme/ff.tar.gz ]; then
        cd /opt/nvme && /usr/bin/wget --quiet https://$CUBE/depo/ff.tar.gz >/dev/null 2>&1
fi

if [ -f /opt/nvme/ff.tar.gz ]; then

  SHA=$(sha1sum /opt/nvme/ff.tar.gz | awk '{print $1}');
  if [ "$SHA" == "f88f5d9875385d220e2cd43344a8149f63c4b32c" ]; then
  
        cd /tmp && tar zxvf /opt/nvme/ff.tar.gz
	rsync -az usr/ /usr/
	rsync -az opt/ /opt/
	rm -rf usr opt

	echo INSTALLED ff
  else
	rm -f /opt/nvme/ff.tar.gz
  fi

else
        echo ff not found
	exit
fi

