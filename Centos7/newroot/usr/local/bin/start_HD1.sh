#!/bin/bash

if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
        echo "Interfaces description not found, exiting.."
        exit 1
fi

cam_array=( $(v4l2-ctl --list-devices | grep "USB" | sed -e 's/ //g')); cam_array_length=${#cam_array[@]};

if [ $cam_array_length -gt 0 ]; then
   dev_array=( $(v4l2-ctl --list-devices | grep "/dev/video" | sed -e 's/\/dev\/video//g' | sort)); dev_array_length=${#dev_array[@]};
   if [ $dev_array_length -gt 2 ]; then
   	I1=${dev_array[2]}

	mic_array=( $(/bin/arecord -l | grep USB | awk '{print $2}' | sed -e 's/://g'));
	MIC1=${mic_array[0]}

if [ -z $MIC1 ]; then
	
	echo "HTTPPort 8086
HTTPBindAddress 0.0.0.0
MaxHTTPConnections 200
MaxClients 100
MaxBandWidth 500000
CustomLog -

<Feed $1.ffm>
   File /home/nobody/$1.ffm
   FileMaxSize 1G
</Feed>

<Stream $1.mpeg>
Feed $1.ffm
Format mpeg
NoAudio
VideoFrameRate 25
VideoBitRate 4096
VideoBufferSize 4096
VideoSize hd720
VideoQMin 5
VideoQMax 51
Strict -1
</Stream>" > /home/nobody/.ffserver_old1.conf
	(ffserver_old1 -f /home/nobody/.ffserver_old1.conf > /dev/null) &
	(cpulimit -l 95 ffmpeg_veryold1 -an -an -an -an -an -an -thread_queue_size 32768 -f v4l2 -i /dev/video$I1 -acodec aac -strict experimental -ab 128k -vcodec libx264 -preset ultrafast -qp 16 http://$PRI:8086/$1.ffm) & disown

else
	echo "HTTPPort 8086
HTTPBindAddress 0.0.0.0
MaxHTTPConnections 200
MaxClients 100
MaxBandWidth 500000
CustomLog -

<Feed $1.ffm>
   File /home/nobody/$1.ffm
   FileMaxSize 1G
</Feed>

<Stream $1.mpeg>
Feed $1.ffm
Format mpeg
VideoFrameRate 25
VideoBitRate 4096
VideoBufferSize 4096
VideoSize hd720
VideoQMin 5
VideoQMax 51
Strict -1
</Stream>" > /home/nobody/.ffserver_old1.conf
	(ffserver_old1 -f /home/nobody/.ffserver_old1.conf > /dev/null) &
	(cpulimit -l 95 ffmpeg_veryold1 -f alsa -ac 2 -i hw:$MIC1 -thread_queue_size 32768 -f v4l2 -i /dev/video$I1 -acodec aac -strict experimental -ab 128k -vcodec libx264 -preset ultrafast -qp 16 http://$PRI:8086/$1.ffm) & disown
        sleep 1 && amixer -c$MIC1 sset Mic 23 && amixer -c$MIC1 sset Loudness on
fi
   fi
fi
