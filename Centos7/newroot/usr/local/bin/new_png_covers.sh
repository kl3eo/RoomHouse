#!/bin/sh
#change covers for R-H/VG

SOFTPAC=`cat /etc/sysconfig/softpac`

ROO="room-house.com"
#if [ $SOFTPAC -eq 7 ]; then
#ROO="validate.guru"
#fi

if [ -s /opt/nvme/ssd/upload/png1.png ]; then
	yes | cp -a /home/nobody/vchat_video/src/main/resources/static/img/people4_$1.png /home/nobody/vchat_video/src/main/resources/static/img/people4_$1_old.png
	yes | cp -a /opt/nvme/ssd/upload/png1.png /home/nobody/vchat_video/src/main/resources/static/img/people4_$1.png && yes | cp -a /opt/nvme/ssd/upload/png1.png /home/nobody/vchat_video/target/classes/static/img/people4_$1.png
fi

if [ -s /opt/nvme/ssd/upload/png2.png ]; then
	yes | cp -a /home/nobody/vchat_video/src/main/resources/static/img/city2_$1.png /home/nobody/vchat_video/src/main/resources/static/img/city2_$1_old.png
	yes | cp -a /opt/nvme/ssd/upload/png2.png /home/nobody/vchat_video/src/main/resources/static/img/city2_$1.png && yes | cp -a /opt/nvme/ssd/upload/png2.png /home/nobody/vchat_video/target/classes/static/img/city2_$1.png
fi

sed -i "s/Room-House\.com/\&nbsp;/g" /home/nobody/vchat/target/classes/static/index.html && sed -i "s/Room-House\.com/\&nbsp;/g" /home/nobody/vchat/src/main/resources/static/index.html
sed -i "s/Validate\.Guru/\&nbsp;/g" /home/nobody/vchat/target/classes/static/index.html && sed -i "s/Validate\.Guru/\&nbsp;/g" /home/nobody/vchat/src/main/resources/static/index.html
sed -i "s/SkyPirl Blockchain/\&nbsp;/g" /home/nobody/vchat/target/classes/static/index.html && sed -i "s/SkyPirl Blockchain/\&nbsp;/g" /home/nobody/vchat/src/main/resources/static/index.html
sed -i "s/&#9733;&#9733;&#9733;/\&nbsp;/g" /home/nobody/vchat/target/classes/static/index.html && sed -i "s/&#9733;&#9733;&#9733;/\&nbsp;/g" /home/nobody/vchat/src/main/resources/static/index.html

echo OK
