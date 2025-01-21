#!/bin/bash

mkdir -p /opt/nvme/home/op/usr/local/bin

if [ ! -f /opt/nvme/home/op/usr/local/bin/gexp ]; then
	cd /opt/nvme/home/op/usr/local/bin/ && /usr/bin/wget --quiet https://$CUBE/depo/gexp >/dev/null 2>&1 && chmod +x gexp
fi

if [ ! -f /opt/nvme/home/op/usr/local/bin/pirl ]; then
	cd /opt/nvme/home/op/usr/local/bin/ && /usr/bin/wget --quiet https://$CUBE/depo/pirl >/dev/null 2>&1 && chmod +x pirl
fi

if [ ! -f /opt/nvme/home/op/usr/local/bin/geth ]; then
	cd /opt/nvme/home/op/usr/local/bin/ && /usr/bin/wget --quiet https://$CUBE/depo/geth >/dev/null 2>&1 && chmod +x geth
fi

SHA=$(sha1sum /opt/nvme/home/op/usr/local/bin/gexp | awk '{print $1}');
if [ "$SHA" != "a7b828ca1951a26840db13e644b599ca7c3ff075" ]; then
	rm -f /opt/nvme/home/op/usr/local/bin/gexp
fi

SHA=$(sha1sum /opt/nvme/home/op/usr/local/bin/geth | awk '{print $1}');
if [ "$SHA" != "5647099a8690a4a5ff2621927916280eccbc6a4e" ]; then
        rm -f /opt/nvme/home/op/usr/local/bin/geth
fi

SHA=$(sha1sum /opt/nvme/home/op/usr/local/bin/pirl | awk '{print $1}');
if [ "$SHA" != "0f0e6bdae3cafac3acbb972decaebfc104a9f28d" ]; then
        rm -f /opt/nvme/home/op/usr/local/bin/pirl
fi

CUBE=cube.xter.tech
RESULT=`/usr/bin/curl --silent  --connect-timeout 2 https://$CUBE/cgi/genc/check`;

if [ ${#RESULT} -eq 0 ]; then
        CUBE=aspen.room-house.com:8448
	RESULT=`/usr/bin/curl --silent  --connect-timeout 2 https://$CUBE/cgi/genc/check`;
fi

if [ $RESULT -ne 1 ]; then
	CUBE=cube.xter.tech
fi

echo Install Video Driver:

STR=`lspci | grep VGA`

if [[ $STR =~ "AMD/ATI" ]]; then

if [ ! -f /opt/nvme/xorg-x11-server-Xorg-1.17.2-22.el7.x86_64.rpm ]; then
        cd /opt/nvme && /usr/bin/wget --quiet https://$CUBE/depo/xorg-x11-server-Xorg-1.17.2-22.el7.x86_64.rpm >/dev/null 2>&1
fi

if [ -f /opt/nvme/xorg-x11-server-Xorg-1.17.2-22.el7.x86_64.rpm ]; then

  SHA=$(sha1sum /opt/nvme/xorg-x11-server-Xorg-1.17.2-22.el7.x86_64.rpm | awk '{print $1}');
  if [ "$SHA" == "0f75df3626cb6eac1040abea5973176ea16f9b5e" ]; then
        yum install -y /opt/nvme/xorg-x11-server-Xorg-1.17.2-22.el7.x86_64.rpm > /dev/null 2>&1
        echo INSTALLED XORG SERVER
  else
	rm -f /opt/nvme/xorg-x11-server-Xorg-1.17.2-22.el7.x86_64.rpm
  fi

else
        echo Xorg server not found
fi


if [ ! -f /opt/nvme/amdgpu-pro-17.40-492261.tar.xz ]; then
        cd /opt/nvme && /usr/bin/wget --quiet https://$CUBE/depo/amdgpu-pro-17.40-492261.tar.xz >/dev/null 2>&1
fi

if [ -f /opt/nvme/amdgpu-pro-17.40-492261.tar.xz ]; then
  SHA=$(sha1sum /opt/nvme/amdgpu-pro-17.40-492261.tar.xz | awk '{print $1}');
  if [ "$SHA" == "836a53ff5cb6e0f0bb2e923bbc2bd1da366e2e19" ]; then
        cd /opt/nvme/ && tar xvf amdgpu-pro-17.40-492261.tar.xz && cd amdgpu-pro-17.40-492261 && ./amdgpu-pro-install -y --nogpgcheck && mv /opt/amdgpu-pro /opt/nvme/ && ln -s /opt/nvme/amdgpu-pro /opt/amdgpu-pro
        echo INSTALLED ATI VIDEO DRIVER
  
  else
  	rm -f /opt/nvme/amdgpu-pro-17.40-492261.tar.xz
  fi

else
        echo ATI Video driver pack not found
fi

fi

#############

if [[ $STR =~ "NVIDIA" ]]; then
#legacy drivers: NVIDIA-Linux-x86_64-390.138.run, using: NVIDIA-Linux-x86_64-450.57.run

if [ ! -f /opt/nvme/add_nvid.tar.gz ]; then
        cd /opt/nvme && wget --quiet https://$CUBE/depo/add_nvid.tar.gz >/dev/null 2>&1
fi

if [ -f /opt/nvme/add_nvid.tar.gz ]; then

  SHA=$(sha1sum /opt/nvme/add_nvid.tar.gz | awk '{print $1}');
  if [ "$SHA" == "97527fdeab9eabba76753cd7c22ed15ec698465c" ]; then
        cd / && tar zxvf /opt/nvme/add_nvid.tar.gz
	echo INSTALLED NVIDIA VIDEO DRIVER
  else
	rm -f /opt/nvme/add_nvid.tar.gz
  fi
	
else
        echo NVIDIA Video driver pack not found
fi

fi
