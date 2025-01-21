#!/bin/bash

I=$1
T=$2
if [ $T -eq 0 ]; then
let I+=2
s="mjpeg_serve$I.py"
elif [ $T -eq 1 ]; then
s="ffmpeg$I"
elif [ $T -eq 2 ]; then
s="ffserver$I"
else
s="ffserver_old$I"
fi

HA=`ps aux | grep $s | grep -v grep`

if [ -z "$HA" ]; then
        echo 0
else
  if [ $T -eq 0 ]; then
    sleep 1 && HA=`ps aux | grep $s | grep -v grep`
    
    if [ -z "$HA" ]; then
	echo 0
    else
        echo 1
    fi
    
  else 
        echo 1
  fi

fi
