#!/bin/bash
if [ $1 -eq 0 ]; then
killall start_OD1.sh && killall python3
elif [ $1 -eq 1 ]; then
PID=( $(ps aux | grep ffmpeg1 | grep -v grep | awk {'print $2'}));
kill -n 9 $PID
elif [ $1 -eq 2 ]; then
PID=( $(ps aux | grep ffmpeg_old1 | grep -v grep | awk {'print $2'}));
kill -n 9 $PID
PID=( $(ps aux | grep ffserver1 | grep -v grep | awk {'print $2'}));
kill -n 9 $PID
else
PID=( $(ps aux | grep ffmpeg_veryold1 | grep -v grep | awk {'print $2'}));
kill -n 9 $PID
PID=( $(ps aux | grep ffserver_old1 | grep -v grep | awk {'print $2'}));
kill -n 9 $PID
fi
