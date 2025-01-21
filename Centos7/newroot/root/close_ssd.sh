#!/bin/bash
closed=false
while [ $closed == false ]
do
  if [ ! -n "`mount | grep /dev/mapper/ssd`" ]; then
	   /usr/bin/cryptsetup close ssd && closed=true
  fi
  #sleep 1
  closed=true
done
