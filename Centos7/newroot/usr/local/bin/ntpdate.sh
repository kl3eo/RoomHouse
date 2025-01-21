#!/bin/bash
/usr/sbin/ntpdate pool.ntp.org
/etc/rc.d/init.d/sendmail restart
