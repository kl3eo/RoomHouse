#!/bin/bash

if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
        echo "Interfaces description not found, exiting.."
        exit 1
fi

SOFTPAC=`cat /etc/sysconfig/softpac`

CUBE=controls.room-house.com
RESULT=`/usr/bin/curl --silent  --connect-timeout 2 https://$CUBE/cgi/genc/check`;

if [ ${#RESULT} -eq 0 ]; then
        CUBE=aspen.room-house.com:8448
	RESULT=`/usr/bin/curl --silent  --connect-timeout 2 https://$CUBE/cgi/genc/check`;
fi

if [ $RESULT -ne 1 ]; then
	CUBE=controls.room-house.com
fi

if [[ "$CLIENTNAME" == "jaja" || "$CLIENTNAME" == "demo" || "$CLIENTNAME" == "rhplus" ]]; then

echo Free media

else

echo Install PHP5 Apache2:


if [ ! -f /opt/nvme/php5.tar.gz ]; then
        cd /opt/nvme && /usr/bin/wget --no-check-certificate --quiet https://$CUBE/depo/php5.tar.gz >/dev/null 2>&1
fi

if [ -f /opt/nvme/php5.tar.gz ]; then

#NB: for chat, wtagonliners, wtagshoutbox and mes_seq should exist in PG db

  SHA=$(sha1sum /opt/nvme/php5.tar.gz | awk '{print $1}');
  if [ "$SHA" == "a822fa16043a8e1f168b84b83f96aae099bb873f" ]; then

        cd /tmp && tar zxvf /opt/nvme/php5.tar.gz

	rsync -az php_addon/usr/local/apache2/modules/ /usr/local/apache2/modules/
	rsync -az php_addon/var/www/html/cp/public_html/ /var/www/html/cp/public_html/
	chown -R nobody:users /var/www/html/cp/public_html/
	rm -rf /tmp/php_addon/
	
	sed -i "s/#LoadModule php5_module/LoadModule php5_module/g" /usr/local/apache2/conf/httpd.conf.http
	sed -i "s/#LoadModule php5_module/LoadModule php5_module/g" /usr/local/apache2/conf/httpd.conf.https
	sed -i "s/#LoadModule php5_module/LoadModule php5_module/g" /usr/local/apache2/conf/httpd.conf
	
	sed -i "s;RewriteRule \\\.php;#RewriteRule \\\.php;g" /usr/local/apache2/conf/httpd.conf.http
	sed -i "s;RewriteRule \\\.php;#RewriteRule \\\.php;g" /usr/local/apache2/conf/httpd.conf.https
	sed -i "s;RewriteRule \\\.php;#RewriteRule \\\.php;g" /usr/local/apache2/conf/httpd.conf
		
	echo INSTALLED PHP5 Apache2
  else
	rm -f /opt/nvme/php5.tar.gz
	cd /opt/nvme && /usr/bin/wget --no-check-certificate --quiet https://$CUBE/depo/php5.tar.gz >/dev/null 2>&1 && SHA=$(sha1sum /opt/nvme/php5.tar.gz | awk '{print $1}');
	  if [ "$SHA" == "a822fa16043a8e1f168b84b83f96aae099bb873f" ]; then

		cd /tmp && tar zxvf /opt/nvme/php5.tar.gz

		rsync -az php_addon/usr/local/apache2/modules/ /usr/local/apache2/modules/
		rsync -az php_addon/var/www/html/cp/public_html/ /var/www/html/cp/public_html/
		chown -R nobody:users /var/www/html/cp/public_html/
		rm -rf /tmp/php_addon/
	
		sed -i "s/#LoadModule/LoadModule/g" /usr/local/apache2/conf/httpd.conf.http
		sed -i "s/#LoadModule/LoadModule/g" /usr/local/apache2/conf/httpd.conf.https
		sed -i "s/#LoadModule/LoadModule/g" /usr/local/apache2/conf/httpd.conf
	
		sed -i "s;RewriteRule \\\.php;#RewriteRule \\\.php;g" /usr/local/apache2/conf/httpd.conf.http
		sed -i "s;RewriteRule \\\.php;#RewriteRule \\\.php;g" /usr/local/apache2/conf/httpd.conf.https
		sed -i "s;RewriteRule \\\.php;#RewriteRule \\\.php;g" /usr/local/apache2/conf/httpd.conf
	
		echo INSTALLED PHP5 Apache2
	else
		rm -f /opt/nvme/php5.tar.gz
		echo Bad PHP archive
	fi
  fi

else
        echo PHP5 Apache2 not found
	exit
fi

if [ $SOFTPAC -eq 5 ]; then

echo Install Cyrus IMAP:


if [ ! -f /opt/nvme/cy.tar.gz ]; then
        cd /opt/nvme && /usr/bin/wget --no-check-certificate --quiet https://$CUBE/depo/cy.tar.gz >/dev/null 2>&1
fi

if [ -f /opt/nvme/cy.tar.gz ]; then
  SHA=$(sha1sum /opt/nvme/cy.tar.gz | awk '{print $1}');
  if [ "$SHA" == "2214f1bf31d1330305d4b15c21ee51091a2c68dd" ]; then

        cd /tmp && tar zxvf /opt/nvme/cy.tar.gz
	rsync -az addon_cyrus/ / && chown -R cyrus:mail /var/lib/imap/ && chown -R cyrus:mail /var/spool/imap/
	rm -rf /tmp/addon_cyrus/ && ldconfig

#hack --ash
#repeating code from check_ssd.sh
	
	if [ -d /opt/nvme/var/spool/imap/ ]; then
		rm -rf /var/spool/imap.orig
		rm -rf /var/spool/imap/
	else
		rm -rf /opt/nvme/var/spool/imap
		mv /var/spool/imap/ /opt/nvme/var/spool/
	fi
	ln -s /opt/nvme/var/spool/imap/ /var/spool/


	if [ -d /opt/nvme/var/lib/imap ]; then
		
		rm -rf /var/lib/imap.orig
		rm -rf /var/lib/imap/
	else
		rm -rf /opt/nvme/var/lib/imap
		mv /var/lib/imap/ /opt/nvme/var/lib/
	fi
	ln -s /opt/nvme/var/lib/imap/ /var/lib/
# end hack
	
	echo INSTALLED Cyrus IMAP
  else
	rm -f /opt/nvme/cy.tar.gz
	cd /opt/nvme && /usr/bin/wget --no-check-certificate --quiet https://$CUBE/depo/cy.tar.gz >/dev/null 2>&1 && SHA=$(sha1sum /opt/nvme/cy.tar.gz | awk '{print $1}');
	  if [ "$SHA" == "2214f1bf31d1330305d4b15c21ee51091a2c68dd" ]; then

	  	cd /tmp && tar zxvf /opt/nvme/cy.tar.gz
		rsync -az addon_cyrus/ / && chown -R cyrus:mail /var/lib/imap/ && chown -R cyrus:mail /var/spool/imap/
		rm -rf /tmp/addon_cyrus/ && ldconfig

		#hack --ash
		#repeating code from check_ssd.sh
	
		if [ -d /opt/nvme/var/spool/imap/ ]; then
			rm -rf /var/spool/imap.orig
			rm -rf /var/spool/imap
		else
			rm -rf /opt/nvme/var/spool/imap
			mv /var/spool/imap/ /opt/nvme/var/spool/
		fi
		ln -s /opt/nvme/var/spool/imap/ /var/spool/


		if [ -d /opt/nvme/var/lib/imap ]; then
		
			rm -rf /var/lib/imap.orig
			rm -rf /var/lib/imap
		else
			rm -rf /opt/nvme/var/lib/imap
			mv /var/lib/imap/ /opt/nvme/var/lib/
		fi
		ln -s /opt/nvme/var/lib/imap/ /var/lib/
		# end hack
	
		echo INSTALLED Cyrus IMAP
	else
        	rm -f /opt/nvme/cy.tar.gz
		echo Bad archive Cyrus
        	exit
	fi
	
  fi

else
        echo Cyrus IMAP not found
	exit
fi

#cyrus for office only, php needed by VG
fi

#not free media edition
fi

echo Install Kurento:

rm -f /opt/nvme/ku.tar.gz

if [ ! -f /opt/nvme/kure.tar.gz ]; then
        cd /opt/nvme && /usr/bin/wget --no-check-certificate --quiet https://$CUBE/depo/kure.tar.gz >/dev/null 2>&1
fi

if [ -f /opt/nvme/kure.tar.gz ]; then
  SHA=$(sha1sum /opt/nvme/kure.tar.gz | awk '{print $1}');
  if [ "$SHA" == "b4c3c13346f977b0f9734c3771bd1175189287c3" ]; then

    cd /home/nobody && rm -rf newlib/ && /bin/openssl enc -d -aes256 -k $OPENSSL -in /opt/nvme/kure.tar.gz -out /opt/nvme/ku.tar.gz && tar zxvf /opt/nvme/ku.tar.gz && rm -f /opt/nvme/ku.tar.gz && mv kure newlib
    mkdir -p /usr/lib/x86_64-linux-gnu && rsync -az newlib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/ && chown -R root /usr/lib/x86_64-linux-gnu && rm -rf newlib/x86_64-linux-gnu/
    rm -f newlib/etc/profile && rsync -az newlib/etc/ /etc/ && rm -rf newlib/etc/ && yes | cp -a /root/cache/office/cert+key.pem /etc/kurento/
    mkdir -p /home/nobody/.cache/gstreamer-1.5/ && cp -a newlib/registry* /home/nobody/.cache/gstreamer-1.5/ && chown -R nobody /home/nobody/.cache/gstreamer-1.5/	
	
    echo INSTALLED Kurento
  else
    rm -f /opt/nvme/kure.tar.gz
    cd /opt/nvme && /usr/bin/wget --no-check-certificate --quiet https://$CUBE/depo/kure.tar.gz >/dev/null 2>&1 && SHA=$(sha1sum /opt/nvme/kure.tar.gz | awk '{print $1}');
    if [ "$SHA" == "b4c3c13346f977b0f9734c3771bd1175189287c3" ]; then
      cd /home/nobody && rm -rf newlib/ && /bin/openssl enc -d -aes256 -k $OPENSSL -in /opt/nvme/kure.tar.gz -out /opt/nvme/ku.tar.gz && tar zxvf /opt/nvme/ku.tar.gz && rm -f /opt/nvme/ku.tar.gz && mv kure newlib
      mkdir -p /usr/lib/x86_64-linux-gnu && rsync -az newlib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/ && chown -R root /usr/lib/x86_64-linux-gnu && rm -rf newlib/x86_64-linux-gnu/
      rm -f newlib/etc/profile && rsync -az newlib/etc/ /etc/ && rm -rf newlib/etc/ && yes | cp -a /root/cache/office/cert+key.pem /etc/kurento/
      mkdir -p /home/nobody/.cache/gstreamer-1.5/ && cp -a newlib/registry* /home/nobody/.cache/gstreamer-1.5/ && chown -R nobody /home/nobody/.cache/gstreamer-1.5/
    else
      rm -f /opt/nvme/kure.tar.gz
      echo Bad archive Kurento
      exit
    fi	
  fi

else
        echo Kurento not found
        exit
fi

echo Install Java:


if [ ! -f /opt/nvme/vlibs.tar.gz ]; then
        cd /opt/nvme && /usr/bin/wget --no-check-certificate --quiet https://$CUBE/depo/vlibs.tar.gz >/dev/null 2>&1
fi

XTERTECH=$XTERTECH:8453
rm -f /opt/nvme/vli.tar.gz

if [ -f /opt/nvme/vlibs.tar.gz ]; then

  if [ "$HOSTNAME" == "corfu" ]; then continue; else XTERTECH=$HOSTNAME.$XTERTECH; fi

  SHA=$(sha1sum /opt/nvme/vlibs.tar.gz | awk '{print $1}');
  if [ "$SHA" == "6319242dde7a3fc09a81434069103aeb38b69d7c" ]; then

        cd /home/nobody && rm -rf vlibs/ && /bin/openssl enc -d -aes256 -k $OPENSSL -in /opt/nvme/vlibs.tar.gz -out /opt/nvme/vli.tar.gz && tar zxvf /opt/nvme/vli.tar.gz && rm -f /opt/nvme/vli.tar.gz
	rsync -Kaz vlibs/ / && rm -rf vlibs/ && yes | cp -a /root/cache/office/cert.p12 /home/nobody/vchat/src/main/resources/ && su -c '/home/nobody/v.sh' - nobody

if [ $SOFTPAC -eq 7 ]; then
	rm -f /home/nobody/vchat && ln -s /home/nobody/vchat_video/ /home/nobody/vchat && su -c '/home/nobody/v.sh' - nobody
fi	      
	echo INSTALLED Java
  else
        rm -f /opt/nvme/vlibs.tar.gz
	cd /opt/nvme && /usr/bin/wget --no-check-certificate --quiet https://$CUBE/depo/vlibs.tar.gz >/dev/null 2>&1 && SHA=$(sha1sum /opt/nvme/vlibs.tar.gz | awk '{print $1}');
	if [ "$SHA" == "6319242dde7a3fc09a81434069103aeb38b69d7c" ]; then

        	cd /home/nobody && rm -rf vlibs/ && /bin/openssl enc -d -aes256 -k $OPENSSL -in /opt/nvme/vlibs.tar.gz -out /opt/nvme/vli.tar.gz && tar zxvf /opt/nvme/vli.tar.gz && rm -f /opt/nvme/vli.tar.gz
		rsync -Kaz vlibs/ / && rm -rf vlibs/ && yes | cp -a /root/cache/office/cert.p12 /home/nobody/vchat_video/src/main/resources/

if [ $SOFTPAC -eq 7 ]; then
	rm -f /home/nobody/vchat && ln -s /home/nobody/vchat_video/ /home/nobody/vchat && su -c '/home/nobody/v.sh' - nobody
fi		        
		echo INSTALLED Java
	else
        	rm -f /opt/nvme/vlibs.tar.gz
		echo Bad archive Vlibs
        	exit  
  	fi
  fi

sed -i '/stunServerAddress=/d' /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini && echo stunServerAddress=$TURNSERVER >> /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini
sed -i '/turnURL=/d' /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini && echo turnURL=alex:shit\@$TURNSERVER:3478 >> /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini


cd /opt/nvme/ssd/my/ && tar zxvf GeoLite2-City_20220208.tar.gz && chown -R nobody:users GeoLite2-City_20220208 && rm -f GeoLite2-City_20220208.tar.gz

chmod 775 /home/nobody/vchat/target/classes/static/

else
        echo Java not found
        exit
fi
