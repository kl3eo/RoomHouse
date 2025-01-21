#!/bin/bash
SALT="eNiGmA"
HA=$1$SALT
STR=`echo $HA | md5sum`; echo ${STR:8:8}
