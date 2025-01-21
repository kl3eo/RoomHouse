#!/bin/bash

if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
        echo "Interfaces description not found, exiting.."
        exit 1
fi

SOFTPAC=`cat /etc/sysconfig/softpac`

CUBE=controls.room-house.com
RESULT=`/usr/bin/curl --silent  --connect-timeout 2 https://$CUBE/cgi/genc/check`;

if [ ${#RESULT} -eq 0 ]; then
        CUBE=aspen.room-house.com:8448
	RESULT=`/usr/bin/curl --silent  --connect-timeout 2 https://$CUBE/cgi/genc/check`;
fi

if [ $RESULT -ne 1 ]; then
	CUBE=controls.room-house.com
fi

rm -f /opt/nvme/ku.tar.gz

if [ -f /opt/nvme/kure.tar.gz ]; then

  cd /home/nobody && rm -rf newlib/ && /bin/openssl enc -d -aes256 -k $OPENSSL -in /opt/nvme/kure.tar.gz -out /opt/nvme/ku.tar.gz && tar zxvf /opt/nvme/ku.tar.gz && rm -f /opt/nvme/ku.tar.gz && mv kure newlib
  mkdir -p /usr/lib/x86_64-linux-gnu && rsync -az newlib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/ && chown -R root /usr/lib/x86_64-linux-gnu && rm -rf newlib/x86_64-linux-gnu/
  rm -f newlib/etc/profile && rsync -az newlib/etc/ /etc/ && rm -rf newlib/etc/
  mkdir -p /home/nobody/.cache/gstreamer-1.5/ && cp -a newlib/registry* /home/nobody/.cache/gstreamer-1.5/ && chown -R nobody /home/nobody/.cache/gstreamer-1.5/	
	
else
        echo Kurento not found
        exit
fi

rm -f /opt/nvme/vli.tar.gz

if [ -f /opt/nvme/vlibs.tar.gz ]; then

  cd /home/nobody && rm -rf vlibs/ && /bin/openssl enc -d -aes256 -k $OPENSSL -in /opt/nvme/vlibs.tar.gz -out /opt/nvme/vli.tar.gz && tar zxvf /opt/nvme/vli.tar.gz && rm -f /opt/nvme/vli.tar.gz
  rsync -Kaz vlibs/ / && rm -rf vlibs/ && yes | cp -a /root/cache/office/cert.p12 /home/nobody/vchat_video/src/main/resources/ && su -c '/home/nobody/v.sh' - nobody

if [ $SOFTPAC -eq 7 ]; then
  rm -f /home/nobody/vchat && ln -s /home/nobody/vchat_video/ /home/nobody/vchat && su -c '/home/nobody/v.sh' - nobody
fi

chmod 775 /home/nobody/vchat/target/classes/static/

else
        echo Java not found
        exit
fi
