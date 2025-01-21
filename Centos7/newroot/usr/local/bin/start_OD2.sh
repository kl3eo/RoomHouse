#!/bin/bash
cam_array=( $(v4l2-ctl --list-devices | grep "USB" | sed -e 's/ //g'));cam_array_length=${#cam_array[@]};

if [ $cam_array_length -gt 1 ]; then
   dev_array=( $(v4l2-ctl --list-devices | grep "/dev/video" | sed -e 's/\/dev\/video//g' | sort));dev_array_length=${#dev_array[@]};
   if [ $dev_array_length -gt 3 ]; then
        D1=${dev_array[0]}
        D2=${dev_array[1]}
        I1=${dev_array[2]}
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
        cd /opt/models/research/Object-detection/ && /usr/local/bin/python3.6 my-object-detection.py -c 2 -d 0 -o 1 -O $D2 -I $I2 -w 2 -q 10 & disown

while true; do
HA=`ps aux | grep mjpeg_serve4 | grep -v grep`

if [ -z "$HA" ]; then
        ret=`/usr/local/bin/python3 /opt/stream/mjpeg_serve4.py $D2 $1`;
        sleep 1;
else
break
fi

done

   fi
fi

