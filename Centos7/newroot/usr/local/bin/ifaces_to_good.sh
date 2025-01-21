#!/bin/bash

cp -a /etc/sysconfig/interfaces /etc/sysconfig/ifaces
find /etc/sysconfig/ifaces -print0 | cpio --null -ov --format=newc | gzip -9 > /etc/sysconfig/ifaces.img
mv /etc/sysconfig/ifaces.img /mnt/sda/efi/etc/sysconfig/interfaces.good
