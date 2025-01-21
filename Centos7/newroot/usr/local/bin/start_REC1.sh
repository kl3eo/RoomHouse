#!/bin/bash

cam_array=( $(v4l2-ctl --list-devices | grep "USB" | sed -e 's/ //g'));cam_array_length=${#cam_array[@]};

if [ $cam_array_length -gt 0 ]; then
   dev_array=( $(v4l2-ctl --list-devices | grep "/dev/video" | sed -e 's/\/dev\/video//g' | sort));dev_array_length=${#dev_array[@]};
   if [ $dev_array_length -gt 2 ]; then
   	I1=${dev_array[2]}

	mic_array=( $(/bin/arecord -l | grep USB | awk '{print $2}' | sed -e 's/://g'));
	MIC1=${mic_array[0]}

if [ -z $MIC1 ]; then
	ffmpeg1 -an -an -an -an -an -an -f video4linux2 -i /dev/video$I1 -vcodec libvpx -b:v 1M /var/www/html/cp/public_html/videos/$1 & disown

else
	ffmpeg1 -f alsa -thread_queue_size 1024 -i hw:$MIC1 -f video4linux2 -thread_queue_size 1024 -i /dev/video$I1 -vcodec libvpx -b:v 1M -filter:v fps=fps=10 -c:a libopus -b:a 128K /var/www/html/cp/public_html/videos/$1 & disown
        sleep 1 && amixer -c$MIC1 sset Mic 23 && amixer -c$MIC1 sset Loudness on
fi

   fi
fi

