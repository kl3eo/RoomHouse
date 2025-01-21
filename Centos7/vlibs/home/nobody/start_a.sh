#!/bin/bash
#change "-Xmx12G" to 3/8 of system's RAM, or more, if no other strong eaters of RAM

NOW=$(date +"%Y-%m-%d-%H-%M"+"av");cd /home/nobody/vchat && /bin/sh /bin/mvn -U clean spring-boot:run -Dspring-boot.run.jvmArguments="-Dkms.url=ws://127.0.0.1:8888/kurento" > log-$NOW.log 2>&1 &
rm -f /home/nobody/vchat/lastlog && ln -s /home/nobody/vchat/log-$NOW.log /home/nobody/vchat/lastlog
