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

echo Install python3:


if [ ! -f /opt/nvme/py3.tar.gz ]; then
        cd /opt/nvme && /usr/bin/wget --quiet https://$CUBE/depo/py3.tar.gz >/dev/null 2>&1
fi

if [ -f /opt/nvme/py3.tar.gz ]; then
  SHA=$(sha1sum /opt/nvme/py3.tar.gz | awk '{print $1}');
  if [ "$SHA" == "b2e3715d3bfdbc2ac5365545db879087ee640261" ]; then

        cd /usr/local/ && tar zxvf /opt/nvme/py3.tar.gz

	echo INSTALLED Python3
  else
	rm -f /opt/nvme/py3.tar.gz
  fi

else
        echo Python3 not found
	exit
fi


#STR=`cat /proc/cpuinfo | grep avx`

#if [[ $STR =~ "avx" ]]; then
I="i3"
#else
#I="celeron"
#fi

if [ ! -f /opt/nvme/tensorflow-1.13.1-cp36-cp36m-linux_x86_64.whl ]; then
        cd /opt/nvme && /usr/bin/wget --quiet https://$CUBE/depo/tensorflow-1.13.1-cp36-cp36m-linux_x86_64_$I.whl -O /opt/nvme/tensorflow-1.13.1-cp36-cp36m-linux_x86_64.whl >/dev/null 2>&1
fi

if [ -f /opt/nvme/tensorflow-1.13.1-cp36-cp36m-linux_x86_64.whl ]; then
  SHA=$(sha1sum /opt/nvme/tensorflow-1.13.1-cp36-cp36m-linux_x86_64.whl | awk '{print $1}');
  if [ "$SHA" == "1f891737f04fdd6b0cf65946ac87bf4d3b46e8c6" ]; then

	/usr/local/bin/pip3 uninstall --yes tensorflow && yes | /usr/local/bin/pip3 install /opt/nvme/tensorflow-1.13.1-cp36-cp36m-linux_x86_64.whl       

  else
        rm -f /opt/nvme/tensorflow-1.13.1-cp36-cp36m-linux_x86_64.whl
  fi

fi
