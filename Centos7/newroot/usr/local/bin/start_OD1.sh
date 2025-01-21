#!/bin/bash
cam_array=( $(v4l2-ctl --list-devices | grep "USB" | sed -e 's/ //g'));cam_array_length=${#cam_array[@]};

if [ $cam_array_length -gt 0 ]; then
   dev_array=( $(v4l2-ctl --list-devices | grep "/dev/video" | sed -e 's/\/dev\/video//g' | sort));dev_array_length=${#dev_array[@]};
   if [ $dev_array_length -gt 2 ]; then
   	D1=${dev_array[0]}
   	D2=${dev_array[1]}
   	I1=${dev_array[2]}
	cd /opt/models/research/Object-detection/ && /usr/local/bin/python3 my-object-detection.py -c 1 -d 0 -o 1 -O $D1 -I $I1 -w 2 -q 10 & disown

while true; do
HA=`ps aux | grep mjpeg_serve3 | grep -v grep`

if [ -z "$HA" ]; then
        ret=`/usr/local/bin/python3 /opt/stream/mjpeg_serve3.py $D1 $1`;
        sleep 1;
else
break
fi

done

   fi
fi

