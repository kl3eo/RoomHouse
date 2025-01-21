#!/bin/bash
my_array=( $(ps aux | grep "my-object-detection.py -c $1" | grep -v grep | sed -e 's/ //g'));my_array_length=${#my_array[@]}; echo $my_array_length
