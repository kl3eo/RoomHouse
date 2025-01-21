#!/bin/bash
a=$(cat /etc/sysconfig/interfaces | grep KEY2 | awk -F= '{print $2}');SALT='EnIgMa';HA=$a$SALT;STR=$(echo $HA | md5sum); echo ${STR:0:32}
