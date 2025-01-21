#!/bin/bash

if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
        echo "Interfaces description not found, exiting.."
        exit 1
fi

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
	
if [ -z $MIC2 ]; then

	echo "HTTPPort 8087
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
NoAudio
Strict -1
</Stream>" > /home/nobody/.ffserver_old2.conf
	(ffserver_old2 -f /home/nobody/.ffserver_old2.conf > /dev/null) &
	(cpulimit -l 95 ffmpeg_veryold2 -an -an -an -an -an -an -thread_queue_size 32768 -f v4l2 -i /dev/video$I2 -acodec aac -strict experimental -ab 128k -vcodec libx264 -preset ultrafast -qp 16 http://$PRI:8087/$1.ffm) & disown

else 
	echo "HTTPPort 8087
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
</Stream>" > /home/nobody/.ffserver_old2.conf
	(ffserver_old2 -f /home/nobody/.ffserver_old2.conf > /dev/null) &
	(cpulimit -l 95 ffmpeg_veryold1 -f alsa -ac 2 -i hw:$MIC2 -thread_queue_size 32768 -f v4l2 -i /dev/video$I2 -acodec aac -strict experimental -ab 128k -vcodec libx264 -preset ultrafast -qp 16 http://$PRI:8087/$1.ffm) & disown
        sleep 1 && amixer -c$MIC2 sset Mic 23 && amixer -c$MIC2 sset Loudness on
fi

   fi
fi

