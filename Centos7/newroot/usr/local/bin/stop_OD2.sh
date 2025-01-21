#!/bin/bash
if [ $1 -eq 0 ]; then
killall start_OD2.sh && killall python3.6
elif [ $1 -eq 1 ]; then
PID=( $(ps aux | grep ffmpeg2 | grep -v grep | awk {'print $2'}));
kill -n 9 $PID
elif [ $1 -eq 2 ]; then
PID=( $(ps aux | grep ffmpeg_old2 | grep -v grep | awk {'print $2'}));
kill -n 9 $PID
PID=( $(ps aux | grep ffserver2 | grep -v grep | awk {'print $2'}));
kill -n 9 $PID
else
PID=( $(ps aux | grep ffmpeg_veryold2 | grep -v grep | awk {'print $2'}));
kill -n 9 $PID
PID=( $(ps aux | grep ffserver_old2 | grep -v grep | awk {'print $2'}));
kill -n 9 $PID
fi
