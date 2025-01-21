#!/bin/bash

if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
	echo "Interfaces description not found, exiting.."
	exit 1
fi

mkdir -p /opt/nvme/ssd && rm -rf /opt/nvme/ssd/data
mv /root/pg_data_stub /opt/nvme/ssd/data
rm -rf /opt/nvme/data && ln -s /opt/nvme/ssd/data /opt/nvme/data

mkdir -p /home/nobody && chown -R nobody:nobody /home/nobody

