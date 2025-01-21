#!/bin/bash
if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
        echo "Interfaces description not found, exiting.."
        exit 1
fi
 
SOFTPAC=`cat /etc/sysconfig/softpac`

ROO="room-house.com"
ALX=`grep ";encoderBitrate" /etc/kurento/modules/kurento/MediaElement.conf.ini`
if [[ "$1" == "1" || (-z "$ALX" && -z "$1") ]]; then
  sed -i '/outputBitrate=/d' /etc/kurento/modules/kurento/MediaElement.conf.ini && echo "outputBitrate=1500000" >> /etc/kurento/modules/kurento/MediaElement.conf.ini
else
  sed -i '/outputBitrate=/d' /etc/kurento/modules/kurento/MediaElement.conf.ini && echo ";outputBitrate=0" >> /etc/kurento/modules/kurento/MediaElement.conf.ini
fi

	(nohup cat /etc/letsencrypt/archive/$ROO/cert1.pem /etc/letsencrypt/archive/$ROO/privkey1.pem > /etc/kurento/cert+key.pem && num=$(ps aux | grep kurento-media-server | grep -v grep | awk '{print $2}'); if [ ! -z $num ]; then kill -9 $num; fi && su -c 'GST_PLUGIN_SCANNER=/usr/lib/x86_64-linux-gnu/gstreamer1.5/gstreamer-1.5/gst-plugin-scanner LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/nobody/newlib/lib/ /home/nobody/newlib/lib64/ld-linux-x86-64.so.2 /home/nobody/newlib/bin/kurento-media-server > /dev/null 2>&1 &' - nobody ) &>/dev/null

	(nohup openssl pkcs12 -export -in /etc/letsencrypt/archive/$ROO/cert1.pem -inkey /etc/letsencrypt/archive/$ROO/privkey1.pem -out /home/nobody/vchat/src/main/resources/cert.p12 -passout pass:123456 && chmod 440 /home/nobody/vchat/src/main/resources/cert.p12 && chown nobody:nobody /home/nobody/vchat/src/main/resources/cert.p12 && mkdir -p /opt/nvme/logs/ && chown -R nobody:nobody /opt/nvme/logs/ && num=$(ps aux | grep GroupCallApp | grep -v grep | awk '{print $2}'); if [ ! -z $num ]; then kill -9 $num; fi && sleep 1 && su -c 'NOW=$(date +"%Y-%m-%d-%H-%M");cd /home/nobody/vchat/ && /bin/mvn -U clean spring-boot:run -Dspring-boot.run.jvmArguments="-Dkms.url=ws://127.0.0.1:8888/kurento" > log-$NOW.log 2>&1 & rm -f /home/nobody/vchat/lastlog && ln -s /home/nobody/vchat/log-$NOW.log /home/nobody/vchat/lastlog' - nobody) &>/dev/null

echo "OK Please stand by while reloading Kurento"
