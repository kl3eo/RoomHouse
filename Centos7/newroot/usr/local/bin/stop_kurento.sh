#!/bin/bash
        num=$(ps aux | grep kurento-media-server | grep -v grep | awk '{print $2}'); if [ ! -z $num ]; then kill -9 $num; fi

        num=$(ps aux | grep GroupCallApp | grep audio | grep -v grep | awk '{print $2}'); if [ ! -z $num ]; then kill -9 $num; fi
        num=$(ps aux | grep GroupCallApp | grep video | grep -v grep | awk '{print $2}'); if [ ! -z $num ]; then kill -9 $num; fi
