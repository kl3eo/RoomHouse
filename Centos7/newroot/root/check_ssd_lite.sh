#!/bin/bash

mkdir -p /opt/nvme/var/www/html/lightsquid/
rm -f /var/www/html/lightsquid/report 
if [ -d /var/www/html/lightsquid/report/ ]; then 
	mv /var/www/html/lightsquid/report/ /opt/nvme/var/www/html/lightsquid/ 
fi
mkdir -p /opt/nvme/var/www/html/lightsquid/report && ln -s /opt/nvme/var/www/html/lightsquid/report/ /var/www/html/lightsquid/
