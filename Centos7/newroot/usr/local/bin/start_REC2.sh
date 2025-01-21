#!/bin/bash

cam_array=( $(v4l2-ctl --list-devices | grep "USB" | sed -e 's/ //g'));cam_array_length=${#cam_array[@]};

if [ $cam_array_length -gt 1 ]; then
   dev_array=( $(v4l2-ctl --list-devices | grep "/dev/video" | sed -e 's/\/dev\/video//g' | sort));dev_array_length=${#dev_array[@]};
   if [ $dev_array_length -gt 3 ]; then

	if [[ $cam_array_length -eq 2 && $dev_array_length -eq 4 ]]; then
		I2=${dev_array[$dev_array_length-1]}
	elif [[ $cam_array_length -eq 2 && $dev_array_length -eq 6 ]]; then
		I2=${dev_array[$dev_array_length-2]}
	else 
		IND=`/usr/local/bin/assess_devs.pl`;
		if [ $IND -eq 1 ]; then
			I2=${dev_array[$dev_array_length-2]}
		else
			I2=${dev_array[$dev_array_length-1]}		 
		fi
	fi
	mic_array=( $(/bin/arecord -l | grep USB | awk '{print $2}' | sed -e 's/://g'));
	MIC2=${mic_array[1]}
	
        #/usr/bin/gst-launch-1.1 v4l2src device=/dev/video$I2 ! videorate! queue ! videoconvert ! videoscale ! video/x-raw,width=640,height=480 ! theoraenc ! queue2 ! mux. pulsesrc device=0 ! volume volume=0.5 ! queue ! audioconvert ! queue! vorbisenc ! mux. oggmux name=mux ! filesink location="/opt/nvme/videos/$1" & disown
	#ffmpeg2 -f alsa -i hw:$MIC2 -i /dev/video$I2 -codec:v libtheora -qscale:v 7 -codec:a libvorbis -qscale:a 5 /opt/nvme/videos/$1 & disown

if [ -z $MIC2 ]; then

	ffmpeg2 -an -an -an -an -an -an -f video4linux2 -i /dev/video$I2 -vcodec libvpx -b:v 1M /var/www/html/cp/public_html/videos/$1 & disown

else

	ffmpeg2 -f alsa -thread_queue_size 1024 -i hw:$MIC2 -f video4linux2 -thread_queue_size 1024 -i /dev/video$I2 -vcodec libvpx -b:v 1M -filter:v fps=fps=10 -c:a libopus -b:a 128K /var/www/html/cp/public_html/videos/$1 & disown
        sleep 1 && amixer -c$MIC2 sset Mic 23 && amixer -c$MIC2 sset Loudness on
fi

   fi
fi

