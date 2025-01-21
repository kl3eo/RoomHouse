#!/bin/bash

sed -i "/$1/d" /etc/sysconfig/blacklist
/root/iptables.sh
