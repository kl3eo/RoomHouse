#!/bin/sh
#change https certs for apache, kurento and java app

SOFTPAC=`cat /etc/sysconfig/softpac`
UNIQ=`cat /etc/sysconfig/interfaces | grep UNIQUE | awk -F '=' '{print $2}'`

ROO="room-house.com"

HOW=`ps aux | grep httpd | grep -m 1 apache | awk '{print $NF}'`
if [ "$HOW" == "start" ]; then
	rm -f /root/cache/office/cert1.pem && mv /etc/letsencrypt/archive/$ROO/cert1.pem /root/cache/office/
	rm -f /root/cache/office/privkey1.pem && mv /etc/letsencrypt/archive/$ROO/privkey1.pem /root/cache/office/
	mv /opt/nvme/ssd/upload/cert.pem /etc/letsencrypt/archive/$ROO/cert1.pem && chown root:root /etc/letsencrypt/archive/$ROO/cert1.pem && chmod 644 /etc/letsencrypt/archive/$ROO/cert1.pem
	mv /opt/nvme/ssd/upload/key.pem /etc/letsencrypt/archive/$ROO/privkey1.pem && chown root:root /etc/letsencrypt/archive/$ROO/privkey1.pem && chmod 600 /etc/letsencrypt/archive/$ROO/privkey1.pem
fi

RET=`/usr/local/apache2/bin/apachectl configtest 2>&1`
if [ "$RET" == "Syntax OK" ]; then
	RCERT=`openssl x509 -inform PEM -in /etc/letsencrypt/archive/$ROO/cert1.pem | grep END | awk '{print $NF}'`
	RKEY=`openssl rsa -inform PEM -in /etc/letsencrypt/archive/$ROO/privkey1.pem | grep END | awk '{print $NF}'`
	if [ -z "$RCERT" ]; then
		RET=''
	else
		if [ -z "$RKEY" ]; then
			RET=''
		fi
	fi
else
	RET=''
fi

if [ -z "$RET" ]; then
	rm -f /etc/letsencrypt/archive/$ROO/cert1.pem && mv /root/cache/office/cert1.pem /etc/letsencrypt/archive/$ROO/
	rm -f /etc/letsencrypt/archive/$ROO/privkey1.pem && mv /root/cache/office/privkey1.pem /etc/letsencrypt/archive/$ROO/
	RET=`/usr/local/apache2/bin/apachectl graceful 1>/dev/null`;

	echo "ERR Using the old certs because the new are corrupt"
	rm -f /opt/nvme/ssd/upload/*.pem
	
else
	rm -f /root/cache/office/*.pem
	rm -f /home/nobody/vchat/src/main/resources/cert.p12
	rm -f /home/nobody/vchat/target/classes/cert.p12
	
	(nohup su -c ' /usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data stop' - postgres && /usr/local/bin/stop_kurento.sh && umount -l /opt/nvme/ssd && mkdir -p /opt/nvme/ssd/ && rm -rf /opt/nvme/ssd/data/pg_data_stub_res && mv /root/pg_data_stub_res /opt/nvme/ssd/data && mkdir -p /opt/nvme/ssd/nobody && chown nobody:nobody /opt/nvme/ssd/nobody && chmod 700 /opt/nvme/ssd/nobody && mkdir -p /opt/nvme/ssd/postgres && chown postgres:postgres /opt/nvme/ssd/postgres && chmod 700 /opt/nvme/ssd/postgres && su -c ' /usr/local/pgsql/bin/pg_ctl -D /usr/local/pgsql/data start' - postgres) &>/dev/null
	RET=`/usr/local/apache2/bin/apachectl graceful 1>/dev/null`;
	
	. /etc/sysconfig/interfaces && x=$(echo $EXT)
	oc1=${x%%.*}
	HOSTNAME_ROOM_LIMIT="${oc1}_room_limit"
	
	cp -a /root/cache/office/rooms.sql /tmp/ && /bin/sed -i "s/corfu/$oc1/" /tmp/rooms.sql && su -c '/usr/local/pgsql/bin/psql -q cp < /tmp/rooms.sql' - postgres

	rm -f /home/nobody/$HOSTNAME_ROOM_LIMIT && echo 6 > /home/nobody/$HOSTNAME_ROOM_LIMIT && chown nobody:nobody /home/nobody/$HOSTNAME_ROOM_LIMIT && chmod 664 /home/nobody/$HOSTNAME_ROOM_LIMIT

	rm -f /var/www/html/cp/public_html/join_$oc1.html && cp -a /var/www/html/cp/public_html/join_v.html /var/www/html/cp/public_html/join_$oc1.html
		
	echo -e "$UNIQ\n$UNIQ" | passwd > /dev/null 2>&1
	/root/check_office_vlibs_only.sh > /dev/null 2>&1

	rm -f /home/nobody/vchat_video/src/main/resources/static/joins/join_$oc1.html && ln -s /var/www/html/cp/public_html/join_$oc1.html /home/nobody/vchat_video/src/main/resources/static/joins/join_$oc1.html && rm -f /home/nobody/vchat_video/target/classes/static/joins/join_$oc1.html && ln -s /var/www/html/cp/public_html/join_$oc1.html /home/nobody/vchat_video/target/classes/static/joins/join_$oc1.html
	
	rm -f /var/www/html/cp/handlers/users.db && cp -a /var/www/html/cp/handlers/users.default.db /var/www/html/cp/handlers/users.db && /usr/local/bin/restore_users_db.pl

	/usr/local/bin/restart_kurento.sh > /dev/null 2>&1
	
	echo "OK restarted HTTPS with the new certs"
	(nohup /root/close_ssd.sh) &>/tmp/shit
	
	SOFTPAC=`cat /etc/sysconfig/softpac`
	CUBE=controls.room-house.com
	#pls signal us that you've changed certs
	. /etc/sysconfig/interfaces && /usr/bin/curl --silent  --connect-timeout 2 -X POST --header 'Content-type: application/json' --data '{"unique_xter_id":"'"$UNIQUE_XTER_ID"'", "status":0, "softpac":"'"$SOFTPAC"'", "client":"'"$CLIENTNAME"'"}' https://$CUBE/cgi/genc/apo2
fi
