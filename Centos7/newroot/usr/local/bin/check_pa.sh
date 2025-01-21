#!/bin/bash

my_array=( $(ps aux | grep pulseaudio | grep -v grep | sed -e 's/ //g'));my_array_length=${#my_array[@]};

if [ $my_array_length -eq 0 ]; then

/usr/bin/pulseaudio --start --log-target=syslog
sleep 3
fi
exit;


