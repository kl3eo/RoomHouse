#!/bin/bash

echo "$1" >> /etc/sysconfig/blacklist
/root/iptables.sh
