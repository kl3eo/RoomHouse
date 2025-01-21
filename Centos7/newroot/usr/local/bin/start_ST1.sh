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

<Stream $1.webm>
  Feed $1.ffm
  Format webm
  NoAudio
  VideoCodec libvpx
  VideoSize 480x360
  VideoFrameRate 30
  PreRoll 15
  StartSendOnKey
  VideoBitRate 200
</Stream>" > /home/nobody/.ffserver1.conf
	(ffserver1 -f /home/nobody/.ffserver1.conf > /dev/null) &
	(cpulimit -l 95 ffmpeg_old1 -an -an -an -an -thread_queue_size 32768 -f video4linux2 -i /dev/video$I1 -preset ultrafast http://$PRI:8086/$1.ffm) & disown

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
</Stream>" > /home/nobody/.ffserver1.conf
	(ffserver1 -f /home/nobody/.ffserver1.conf > /dev/null) &
	(cpulimit -l 95 ffmpeg_old1 -f alsa -thread_queue_size 1024 -i hw:$MIC1 -f video4linux2 -i /dev/video$I1 -preset ultrafast http://$PRI:8086/$1.ffm) & disown
	sleep 1 && amixer -c$MIC1 sset Mic 23 && amixer -c$MIC1 sset Loudness on
fi
   fi
fi
