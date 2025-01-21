#!/bin/bash
DATE=`cat /usr/local/var/ipcad/ipcad.date`
(/usr/bin/rsh localhost dump ipcad-$DATE.dump && /usr/bin/rsh localhost clear ip accounting) >/dev/null 2>&1
