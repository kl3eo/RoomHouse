#!/bin/bash

sed -i "/$1/d" /etc/sysconfig/whitelist
/root/iptables.sh
