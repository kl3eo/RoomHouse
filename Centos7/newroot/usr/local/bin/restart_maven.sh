#!/bin/bash

if [ "$1" == "audio" ]; then

num=$(ps aux | grep GroupCallApp | grep -v grep | grep audio | awk '{print $2}'); if [ ! -z $num ]; then kill -9 $num; fi && sleep 1 && su -c '/home/nobody/start_a.sh &' - nobody

elif [ "$1" == "video" ]; then

num=$(ps aux | grep GroupCallApp | grep -v grep | grep video | awk '{print $2}'); if [ ! -z $num ]; then kill -9 $num; fi && sleep 1 && su -c '/home/nobody/start_v.sh &' - nobody

fi

exit;
