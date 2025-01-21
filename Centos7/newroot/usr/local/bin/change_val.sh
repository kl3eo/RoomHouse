#!/bin/bash
if [ -f /etc/sysconfig/interfaces.new ]; then
    . /etc/sysconfig/interfaces.new
else
        echo "Interfaces description not found, exiting.."
        exit 1
fi

#echo "Here par is $1, val is $2!" >> /tmp/log

SOFTPAC=`cat /etc/sysconfig/softpac`

if [ $1 -eq 1 ]; then	
	sed -i "s/.*PRI=.*/PRI=$2/" /etc/sysconfig/interfaces.new
elif [ $1 -eq 2 ]; then
        sed  -i "s/.*PRI_GW=.*/PRI_GW=$2/" /etc/sysconfig/interfaces.new
elif [ $1 -eq 3 ]; then
        sed  -i "s/.*EXT=.*/EXT=$2/" /etc/sysconfig/interfaces.new
	if [ -f /etc/sysconfig/interfaces.saved ]; then 
	  sed  -i "s/.*EXT=.*/EXT=$2/" /etc/sysconfig/interfaces.saved 
	fi
	
	sed -i '/turnURL=/d' /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini && service coturn stop && sleep 1 && sed  -i "s/.*externalIPv4=.*/externalIPv4=$2/" /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini && /usr/local/bin/restart_kurento.sh
	sed  -i "s/$EXT/$2/" /usr/local/apache2/conf/httpd.conf && /usr/local/apache2/bin/apachectl restart
	x=$(echo $2)
	oc1=${x%%.*}
	if [ $SOFTPAC -eq 7 ]; then

		/usr/local/pgsql/bin/psql -U postgres -d cp -tc "INSERT INTO rooms (name) VALUES ('$oc1')"
		
		HOSTNAME_ROOM_LIMIT="${oc1}_room_limit"
		if [ ! -f /home/nobody/$HOSTNAME_ROOM_LIMIT ]; then
			echo 6 > /home/nobody/$HOSTNAME_ROOM_LIMIT && chown nobody:nobody /home/nobody/$HOSTNAME_ROOM_LIMIT && chmod 664 /home/nobody/$HOSTNAME_ROOM_LIMIT
		fi
		
		if [ ! -f /home/nobody/vchat_video/src/main/resources/static/img/city2_$oc1.room-house.com.png ]; then
			ln -s /home/nobody/vchat_video/src/main/resources/static/img/bg_slider.png /home/nobody/vchat_video/src/main/resources/static/img/city2_$oc1.room-house.com.png
		fi 
		
		if [ ! -f /home/nobody/vchat_video/src/main/resources/static/img/people4_$oc1.room-house.com.png ]; then
			ln -s /home/nobody/vchat_video/src/main/resources/static/img/bg_slider.png /home/nobody/vchat_video/src/main/resources/static/img/people4_$oc1.room-house.com.png
		fi

		if [ ! -f /home/nobody/vchat_video/src/main/resources/static/textures/"$oc1"_hallA.jpg ]; then
			rm -f /home/nobody/vchat_video/src/main/resources/static/textures/"$oc1"_hallA.jpg && ln -s /home/nobody/vchat_video/src/main/resources/static/textures/hallA.jpg /home/nobody/vchat_video/src/main/resources/static/textures/"$oc1"_hallA.jpg
			rm -f /home/nobody/vchat_video/target/classes/static/textures/"$oc1"_hallA.jpg && ln -s /home/nobody/vchat_video/target/classes/static/textures/hallA.jpg /home/nobody/vchat_video/target/classes/static/textures/"$oc1"_hallA.jpg
		fi
				
		if [ ! -f /var/www/html/cp/public_html/join_$oc1.html ]; then
		  rm -f /var/www/html/cp/public_html/join_$oc1.html && cp -a /var/www/html/cp/public_html/join_v.html /var/www/html/cp/public_html/join_$oc1.html
		  rm -f /home/nobody/vchat_video/src/main/resources/static/joins/join_$oc1.html && ln -s /var/www/html/cp/public_html/join_$oc1.html /home/nobody/vchat_video/src/main/resources/static/joins/join_$oc1.html && rm -f /home/nobody/vchat_video/target/classes/static/joins/join_$oc1.html && ln -s /var/www/html/cp/public_html/join_$oc1.html /home/nobody/vchat_video/target/classes/static/joins/join_$oc1.html
		fi
	fi
elif [ $1 -eq 4 ]; then
	a=$(echo $2 | sed 's/\//\\\//g')
	sed  -i "s/.*externalIPv4=.*/;externalIPv4=$2/" /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini && sed -i '/turnURL=/d' /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini && echo turnURL=alex:shit\@$a:3478 >> /etc/kurento/modules/kurento/WebRtcEndpoint.conf.ini && sed  -i "s/.*TURNSERVER=.*/TURNSERVER=$a/" /etc/sysconfig/interfaces.new && sed  -i "s/.*TURNSERVER=.*/TURNSERVER=$a/" /etc/sysconfig/interfaces && service coturn start && /usr/local/bin/restart_kurento.sh
	if [ -f /etc/sysconfig/interfaces.saved ]; then 
		sed  -i "s/.*TURNSERVER=.*/TURNSERVER=$a/" /etc/sysconfig/interfaces.saved 
	fi
elif [ $1 -eq 5 ]; then
        sed  -i "s/.*WLAN_IP=.*/WLAN_IP=$2/" /etc/sysconfig/interfaces.new
elif [ $1 -eq 6 ]; then
        sed  -i "s/.*SSID=.*/SSID=$2/" /etc/sysconfig/interfaces.new
	sed -i "s/ssid=.*/ssid=$2/g" /etc/hostapd/hostapd.conf
elif [ $1 -eq 7 ]; then
        sed  -i "s/.*KEY1=.*/KEY1=$2/" /etc/sysconfig/interfaces.new
	WIFIPASS=`/usr/local/bin/chip8.sh $2`
	sed -i "s/wpa_passphrase=.*/wpa_passphrase=$WIFIPASS/g" /etc/hostapd/hostapd.conf
elif [ $1 -eq 8 ]; then
        sed  -i "s/.*KEY2=.*/KEY2=$2/" /etc/sysconfig/interfaces.new
elif [ $1 -eq 9 ]; then
        OLDHOSTNAME=`cat /etc/sysconfig/interfaces.new | grep HOSTNAME | awk -F '=' '{print $2}'`;
        XTERTECH=`cat /etc/sysconfig/interfaces.new | grep XTERTECH | awk -F '=' '{print $2}'`;
        OLDNAME=$OLDHOSTNAME.$XTERTECH
        NEWNAME=$2.$XTERTECH

        sed  -i "s/.*HOSTNAME=.*/HOSTNAME=$2/" /etc/sysconfig/interfaces.new
        sed  -i "s/.*HOSTNAME=.*/HOSTNAME=$2/" /etc/sysconfig/interfaces.saved
        echo export HOSTNAME=$2 > /etc/profile.d/sh.local
        /bin/hostname -b $2

        sed -i "s/demo.xter.tech/$NEWNAME/g" /usr/local/apache2/conf/httpd.conf && sed -i "s/$OLDNAME/$NEWNAME/g" /usr/local/apache2/conf/httpd.conf && /usr/local/apache2/bin/apachectl restart
		
	if [ $SOFTPAC -eq 7 ]; then

		#/usr/local/pgsql/bin/psql -U postgres -d cp -tc "DELETE from rooms where name = '$OLDHOSTNAME'"
		OLDHOSTNAME_ROOM_LIMIT="${OLDHOSTNAME}_room_limit"
		#rm -f /var/www/html/cp/public_html/join_$OLDHOSTNAME.html && rm -f /var/www/html/cp/public_html/join_$2.html && rm -f /var/www/html/cp/public_html/join_REDHALL.html && rm -f /var/www/html/cp/public_html/join_BLUEHALL.html && rm -f /var/www/html/cp/public_html/join_GREENHALL.html && rm -f /home/nobody/$OLDHOSTNAME_ROOM_LIMIT
		rm -f /var/www/html/cp/public_html/join_$2.html && rm -f /var/www/html/cp/public_html/join_REDHALL.html && rm -f /var/www/html/cp/public_html/join_BLUEHALL.html && rm -f /var/www/html/cp/public_html/join_GREENHALL.html

		if [ ! -f /var/www/html/cp/public_html/join_$2.html ]; then
			rm -f /home/nobody/vchat_video/src/main/resources/static/joins/join_$2.html
			rm -f /home/nobody/vchat_video/target/classes/static/joins/join_$2.html

			rm -f /home/nobody/vchat_video/src/main/resources/static/joins/join_*HALL.html
			rm -f /home/nobody/vchat_video/target/classes/static/joins/join_*HALL.html
						
			cd /var/www/html/cp/public_html/ && ln -s join_v.html join_$2.html
			ln -s /var/www/html/cp/public_html/join_$2.html /var/www/html/cp/public_html/join_GREENHALL.html
			ln -s /var/www/html/cp/public_html/join_$2.html /var/www/html/cp/public_html/join_REDHALL.html
			ln -s /var/www/html/cp/public_html/join_$2.html /var/www/html/cp/public_html/join_BLUEHALL.html
			
			ln -s /var/www/html/cp/public_html/join_$2.html /home/nobody/vchat_video/src/main/resources/static/joins/
			ln -s /var/www/html/cp/public_html/join_GREENHALL.html /home/nobody/vchat_video/src/main/resources/static/joins/
			ln -s /var/www/html/cp/public_html/join_REDHALL.html /home/nobody/vchat_video/src/main/resources/static/joins/
			ln -s /var/www/html/cp/public_html/join_BLUEHALL.html /home/nobody/vchat_video/src/main/resources/static/joins/
			
			ln -s /var/www/html/cp/public_html/join_$2.html /home/nobody/vchat_video/target/classes/static/joins/
			ln -s /var/www/html/cp/public_html/join_GREENHALL.html /home/nobody/vchat_video/target/classes/static/joins/
			ln -s /var/www/html/cp/public_html/join_REDHALL.html /home/nobody/vchat_video/target/classes/static/joins/
			ln -s /var/www/html/cp/public_html/join_BLUEHALL.html /home/nobody/vchat_video/target/classes/static/joins/
		fi
				
		#foyer default 2 rooms
		/usr/local/pgsql/bin/psql -U postgres -d cp -tc "INSERT INTO rooms (name, num_rooms) VALUES ('$2', 2)"
	
		HOSTNAME_ROOM_LIMIT="${2}_room_limit"
		if [ ! -f /home/nobody/$HOSTNAME_ROOM_LIMIT ]; then
			echo 6 > /home/nobody/$HOSTNAME_ROOM_LIMIT && chown nobody:nobody /home/nobody/$HOSTNAME_ROOM_LIMIT && chmod 664 /home/nobody/$HOSTNAME_ROOM_LIMIT
		fi
		
		if [ ! -f /home/nobody/vchat_video/src/main/resources/static/img/city2_$2.room-house.com.png ]; then
			ln -s /home/nobody/vchat_video/src/main/resources/static/img/city2.png /home/nobody/vchat_video/src/main/resources/static/img/city2_$2.room-house.com.png
			ln -s /home/nobody/vchat_video/target/classes/static/img/city2.png /home/nobody/vchat_video/target/classes/static/img/city2_$2.room-house.com.png
		fi 
		
		if [ ! -f /home/nobody/vchat_video/src/main/resources/static/img/people4_$2.room-house.com.png ]; then
			ln -s /home/nobody/vchat_video/src/main/resources/static/img/people4.png /home/nobody/vchat_video/src/main/resources/static/img/people4_$2.room-house.com.png
			ln -s /home/nobody/vchat_video/target/classes/static/img/people4.png /home/nobody/vchat_video/target/classes/static/img/people4_$2.room-house.com.png
		fi

		if [ ! -f /home/nobody/vchat_video/src/main/resources/static/textures/$2_hallA.jpg ]; then
			ln -s /home/nobody/vchat_video/src/main/resources/static/textures/hallA.jpg /home/nobody/vchat_video/src/main/resources/static/textures/$2_hallA.jpg
			ln -s /home/nobody/vchat_video/target/classes/static/textures/hallA.jpg /home/nobody/vchat_video/target/classes/static/textures/$2_hallA.jpg
		fi
	fi
	
elif [ $1 -eq 10 ]; then
        sed  -i '/KEY6=/d' /etc/sysconfig/interfaces.new
	echo "KEY6=$2" >> /etc/sysconfig/interfaces.new
elif [ $1 -eq 11 ]; then
        sed  -i '/MAIL=/d' /etc/sysconfig/interfaces.new
	echo "MAIL=$2" >> /etc/sysconfig/interfaces.new
        sed  -i '/MAIL=/d' /etc/sysconfig/interfaces.saved
	echo "MAIL=$2" >> /etc/sysconfig/interfaces.saved
elif [ $1 -eq 12 ]; then
        sed  -i '/SMS=/d' /etc/sysconfig/interfaces.new
	echo "SMS=$2" >> /etc/sysconfig/interfaces.new
        sed  -i '/SMS=/d' /etc/sysconfig/interfaces.saved
	echo "SMS=$2" >> /etc/sysconfig/interfaces.saved
elif [ $1 -eq 13 ]; then	
	sed -i "s/.*SEC=.*/SEC=$2/" /etc/sysconfig/interfaces.new
elif [ $1 -eq 14 ]; then
	a=$(echo $2 | sed 's/\//\\\//g')
        sed  -i "s/.*SEC_NET=.*/SEC_NET=$a/" /etc/sysconfig/interfaces.new
elif [ $1 -eq 15 ]; then
        sed  -i "s/.*SEC_GW=.*/SEC_GW=$2/" /etc/sysconfig/interfaces.new
elif ( [ $1 -eq 16 ] && [ $SOFTPAC -eq 5 ] ); then
        if [ $2 == "true" ]; then
		/sbin/route del default gw $PRI_GW && /sbin/route del default $PRI_IF && /sbin/route add default $SEC_IF && /sbin/route add default gw $SEC_GW
	else
		/sbin/route del default gw $SEC_GW && /sbin/route del default $SEC_IF && /sbin/route add default $PRI_IF && /sbin/route add default gw $PRI_GW
	fi
#hack ash
elif ( [ $1 -eq 16 ] && [ "$CLIENTNAME" == "jaja" ] ); then
	su -c 'nohup ssh -N -L :8080:127.0.0.1:3128 info5@zanzi80 > /dev/null 2>&1 &' - postgres
elif [ $1 -eq 17 ]; then

#echo "Here val is $2!" >> /tmp/log

        if [ $2 == "false" ]; then
		#/sbin/ifconfig $WLAN_IF down
		service hostapd stop
		service dhcpd stop
		/sbin/ifconfig $WLAN_IF down
	else
		#/sbin/ifconfig $WLAN_IF $WLAN_IP
		service hostapd start
		service dhcpd start
	fi

elif [ $1 -eq 18 ]; then
        echo $2 > /home/op/home/op/coinbase

elif [ $1 -eq 19 ]; then
 	(echo $2; echo $2;) | /bin/passwd op

elif [ $1 -eq 20 ]; then
        echo $2 > /home/op/home/op/miner_target
elif [ $1 -eq 25 ]; then
#hack ash; piggyback chairs on a new room creation to full scope of things required for a new tower
		
		HOSTNAME_ROOM_LIMIT="${3}_room_limit"
		echo $2 > /home/nobody/$HOSTNAME_ROOM_LIMIT && chown nobody:nobody /home/nobody/$HOSTNAME_ROOM_LIMIT && chmod 664 /home/nobody/$HOSTNAME_ROOM_LIMIT

		if [ ! -f /home/nobody/vchat_video/src/main/resources/static/textures/$3_hallA.jpg ]; then
			ln -s /home/nobody/vchat_video/src/main/resources/static/textures/hallA.jpg /home/nobody/vchat_video/src/main/resources/static/textures/$3_hallA.jpg
			ln -s /home/nobody/vchat_video/target/classes/static/textures/hallA.jpg /home/nobody/vchat_video/target/classes/static/textures/$3_hallA.jpg
		fi
elif [ $1 -eq 27 ]; then
        HOSTNAME=`cat /etc/sysconfig/interfaces.new | grep HOSTNAME | awk -F '=' '{print $2}'`;
        OLDXTERTECH=`cat /etc/sysconfig/interfaces.new | grep XTERTECH | awk -F '=' '{print $2}'`;
        OLDNAME=$HOSTNAME.$OLDXTERTECH
        NEWNAME=$HOSTNAME.$2

        sed  -i "s/.*XTERTECH=.*/XTERTECH=$2/" /etc/sysconfig/interfaces.new
        sed  -i "s/.*XTERTECH=.*/XTERTECH=$2/" /etc/sysconfig/interfaces.saved

        sed -i "s/demo.xter.tech/$NEWNAME/g" /usr/local/apache2/conf/httpd.conf && sed -i "s/$OLDNAME/$NEWNAME/g" /usr/local/apache2/conf/httpd.conf && /usr/local/apache2/bin/apachectl restart

elif [ $1 -eq 28 ]; then
rm -f /home/nobody/vchat_video/target/classes/static/img/city2_$2.room-house.com.png && ln -s /home/nobody/vchat_video/target/classes/static/img/blue_screen.jpg /home/nobody/vchat_video/target/classes/static/img/city2_$2.room-house.com.png && rm -f /home/nobody/vchat_video/src/main/resources/static/img/city2_$2.room-house.com.png && ln -s /home/nobody/vchat_video/src/main/resources/static/img/blue_screen.jpg /home/nobody/vchat_video/src/main/resources/static/img/city2_$2.room-house.com.png

elif [ $1 -eq 29 ]; then
rm -f /home/nobody/vchat_video/target/classes/static/img/city2_$2.room-house.com.png && ln -s /home/nobody/vchat_video/target/classes/static/img/city2.png /home/nobody/vchat_video/target/classes/static/img/city2_$2.room-house.com.png && rm -f /home/nobody/vchat_video/src/main/resources/static/img/city2_$2.room-house.com.png && ln -s /home/nobody/vchat_video/src/main/resources/static/img/city2.png /home/nobody/vchat_video/src/main/resources/static/img/city2_$2.room-house.com.png
		
fi

#fucccck
if [ ! -f /etc/sysconfig/interfaces.saved ]; then
  rm -f /etc/sysconfig/interfaces.saved && cp -a /etc/sysconfig/interfaces.new /etc/sysconfig/interfaces.saved
fi
