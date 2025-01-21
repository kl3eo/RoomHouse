#!/bin/sh
#change textures in 3d walls

if [ -s /opt/nvme/ssd/upload/jpg1.jpg ]; then
	rm -f /home/nobody/vchat_video/src/main/resources/static/textures/$1_hallA.jpg && yes | cp -a /opt/nvme/ssd/upload/jpg1.jpg /home/nobody/vchat_video/src/main/resources/static/textures/$1_hallA.jpg && mkdir -p /home/nobody/vchat_video/target/classes/static/textures/ && rm -f /home/nobody/vchat_video/target/classes/static/textures/$1_hallA.jpg && yes | cp -a /opt/nvme/ssd/upload/jpg1.jpg /home/nobody/vchat_video/target/classes/static/textures/$1_hallA.jpg && rm -f /opt/nvme/ssd/upload/jpg1.jpg
fi

if [ -s /opt/nvme/ssd/upload/jpg2.jpg ]; then
	rm -f /home/nobody/vchat_video/src/main/resources/static/textures/$1_hallB.jpg && yes | cp -a /opt/nvme/ssd/upload/jpg2.jpg /home/nobody/vchat_video/src/main/resources/static/textures/$1_hallB.jpg && mkdir -p /home/nobody/vchat_video/target/classes/static/textures/ && rm -f /home/nobody/vchat_video/target/classes/static/textures/$1_hallB.jpg && yes | cp -a /opt/nvme/ssd/upload/jpg2.jpg /home/nobody/vchat_video/target/classes/static/textures/$1_hallB.jpg && rm -f /opt/nvme/ssd/upload/jpg2.jpg
fi

if [ -s /opt/nvme/ssd/upload/jpg3.jpg ]; then
	rm -f /home/nobody/vchat_video/src/main/resources/static/textures/$1_hallC.jpg && yes | cp -a /opt/nvme/ssd/upload/jpg3.jpg /home/nobody/vchat_video/src/main/resources/static/textures/$1_hallC.jpg && mkdir -p /home/nobody/vchat_video/target/classes/static/textures/ && rm -f /home/nobody/vchat_video/target/classes/static/textures/$1_hallC.jpg && yes | cp -a /opt/nvme/ssd/upload/jpg3.jpg /home/nobody/vchat_video/target/classes/static/textures/$1_hallC.jpg && rm -f /opt/nvme/ssd/upload/jpg3.jpg
fi

if [ -s /opt/nvme/ssd/upload/jpg4.jpg ]; then
	rm -f /home/nobody/vchat_video/src/main/resources/static/textures/$1_hallD.jpg && yes | cp -a /opt/nvme/ssd/upload/jpg4.jpg /home/nobody/vchat_video/src/main/resources/static/textures/$1_hallD.jpg && mkdir -p /home/nobody/vchat_video/target/classes/static/textures/ && rm -f /home/nobody/vchat_video/target/classes/static/textures/$1_hallD.jpg && yes | cp -a /opt/nvme/ssd/upload/jpg4.jpg /home/nobody/vchat_video/target/classes/static/textures/$1_hallD.jpg && rm -f /opt/nvme/ssd/upload/jpg4.jpg
fi

if [ -s /opt/nvme/ssd/upload/jpg5.jpg ]; then
	rm -f /home/nobody/vchat_video/src/main/resources/static/textures/$1_hallE.jpg && yes | cp -a /opt/nvme/ssd/upload/jpg5.jpg /home/nobody/vchat_video/src/main/resources/static/textures/$1_hallE.jpg && mkdir -p /home/nobody/vchat_video/target/classes/static/textures/ && rm -f /home/nobody/vchat_video/target/classes/static/textures/$1_hallE.jpg && yes | cp -a /opt/nvme/ssd/upload/jpg5.jpg /home/nobody/vchat_video/target/classes/static/textures/$1_hallE.jpg && rm -f /opt/nvme/ssd/upload/jpg5.jpg
fi

if [ -s /opt/nvme/ssd/upload/jpg6.jpg ]; then
	rm -f /home/nobody/vchat_video/src/main/resources/static/textures/$1_hallF.jpg && yes | cp -a /opt/nvme/ssd/upload/jpg6.jpg /home/nobody/vchat_video/src/main/resources/static/textures/$1_hallF.jpg && mkdir -p /home/nobody/vchat_video/target/classes/static/textures/ && rm -f /home/nobody/vchat_video/target/classes/static/textures/$1_hallF.jpg && yes | cp -a /opt/nvme/ssd/upload/jpg6.jpg /home/nobody/vchat_video/target/classes/static/textures/$1_hallF.jpg && rm -f /opt/nvme/ssd/upload/jpg6.jpg
fi

echo OK
