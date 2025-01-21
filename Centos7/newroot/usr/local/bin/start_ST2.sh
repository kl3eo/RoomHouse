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

<Stream $1.webm>
  Feed $1.ffm
  Format webm
  NoAudio
  VideoCodec libvpx
  VideoSize 480x360
  VideoFrameRate 10
  PreRoll 15
  StartSendOnKey
  VideoBitRate 200
</Stream>" > /home/nobody/.ffserver2.conf
	(ffserver2 -f /home/nobody/.ffserver2.conf > /dev/null) &
	(cpulimit -l 95 ffmpeg_old2 -an -an -an -an -thread_queue_size 32768 -f video4linux2 -i /dev/video$I2 -preset ultrafast http://$PRI:8087/$1.ffm) & disown

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

<Stream $1.webm>
  Feed $1.ffm
  Format webm
  AudioCodec vorbis
  AudioBitRate 48
  #  AudioCodec         libopus
  #  AudioBitRate       48
  #  AudioChannels      1
  #  AudioSampleRate    48000
  #  AVOptionAudio      flags +global_header
  VideoCodec libvpx
  VideoSize 480x360
  VideoFrameRate 10
  PreRoll 15
  StartSendOnKey
  VideoBitRate 200
</Stream>" > /home/nobody/.ffserver2.conf
	(ffserver2 -f /home/nobody/.ffserver2.conf > /dev/null) &
	(cpulimit -l 95 ffmpeg_old2 -f alsa -thread_queue_size 1024 -i hw:$MIC2 -f video4linux2 -i /dev/video$I2 -preset ultrafast http://$PRI:8087/$1.ffm) & disown
        sleep 1 && amixer -c$MIC2 sset Mic 23 && amixer -c$MIC2 sset Loudness on
fi
   fi
fi

