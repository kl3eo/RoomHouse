#!/bin/bash

echo "$1" >> /etc/sysconfig/whitelist
/root/iptables.sh
