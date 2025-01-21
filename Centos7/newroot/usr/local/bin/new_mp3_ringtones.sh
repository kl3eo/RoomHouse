#!/bin/sh
#change covers for R-H/VG

SOFTPAC=`cat /etc/sysconfig/softpac`

ROO="room-house.com"
#if [ $SOFTPAC -eq 7 ]; then
#ROO="validate.guru"
#fi

if [ -s /opt/nvme/ssd/upload/mp31.mp3 ]; then
	yes | cp -a /home/nobody/vchat_video/src/main/resources/static/sounds/wood_$1.mp3 /home/nobody/vchat_video/src/main/resources/static/sounds/wood_$1_old.mp3
	yes | cp -a /opt/nvme/ssd/upload/mp31.mp3 /home/nobody/vchat_video/src/main/resources/static/sounds/wood_$1.mp3 && yes | cp -a /opt/nvme/ssd/upload/mp31.mp3 /home/nobody/vchat_video/target/classes/static/sounds/wood_$1.mp3
fi

echo OK
