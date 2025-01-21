#!/bin/bash

num=$(ps aux | grep GroupCallApp | grep -v grep | grep -E '(audio|video)' | awk '{print $2}'); if [ ! -z $num ]; then kill -9 $num; fi && sleep 1 && /home/nobody/start_a.sh

