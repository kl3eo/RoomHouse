#!/bin/bash

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

CUBE=controls.room-house.com
ALTCUBE=aspen.room-house.com:8448

softpac=0
CURRENT_COUNTER=$(cat /etc/sysconfig/counter)
HA=0

if [ -f "/etc/sysconfig/softpac" ]; then
        softpac=$(cat /etc/sysconfig/softpac)
fi


. /etc/sysconfig/interfaces && HAA=`/root/pad_zeros.pl $PRI |  tr -d '\012\015'`
HA=`/usr/local/pgsql/bin/psql -Upostgres -dipaudit -tc "select sum(ip1bytes) + sum(ip2bytes) as sum from ipaudit where protocol=17 and (ip1 = '$HAA' or ip2 = '$HAA') and ip1port != 3478 and ip2port != 3478 and ip1port != 53 and ip2port != 53 and current_timestamp - constart < '1 min'" |  tr -d '\012\015' | awk '{print $1'}`

DEL=`/usr/local/pgsql/bin/psql -Upostgres -dipaudit -tc "delete from ipaudit where protocol=17 and (ip1 = '$HAA' or ip2 = '$HAA') and ip1port != 3478 and ip2port != 3478 and ip1port != 53 and ip2port != 53 and current_timestamp - constart < '1 min'"`

if [ "$HA" == "" ]; then 
	HA=0 
fi

MYNAME=$HOSTNAME.$XTERTECH
CPULOAD=`top -d 0.5 -b -n2 | grep "Cpu(s)" | tail -n 1 | awk '{print $2 + $4}'`

sleep $(( ( RANDOM % 12 )  + 1 )) && . /etc/sysconfig/interfaces && RESULT=`/usr/bin/curl --silent -X POST --header 'Content-type: application/json' --data '{"unique_xter_id":"'"$UNIQUE_XTER_ID"'", "status":0, "softpac":"'"$softpac"'", "client":"'"$CLIENTNAME"'", "turn":"'"$TURNSERVER"'", "kurento_diff":"'"$HA"'", "myname":"'"$MYNAME"'", "cpuload":"'"$CPULOAD"'"}' --connect-timeout 2 https://$CUBE/cgi/genc/apo2` && ALTRESULT=`/usr/bin/curl --silent -X POST --header 'Content-type: application/json' --data '{"unique_xter_id":"'"$UNIQUE_XTER_ID"'", "status":0, "softpac":"'"$softpac"'", "client":"'"$CLIENTNAME"'", "turn":"'"$TURNSERVER"'", "kurento_diff":"'"$HA"'", "myname":"'"$MYNAME"'", "cpuload":"'"$CPULOAD"'"}' --connect-timeout 2 https://$ALTCUBE/cgi/genc/apo2`

if [ ${#RESULT} -eq 0 ]; then
        RESULT=$ALTRESULT
fi

if [ ${#RESULT} -eq 0 ]; then
        RESULT=-1
fi

if valid_ip $RESULT; then 
	stat='good';
	sed -i '/TURNSERVER=/d' /etc/sysconfig/interfaces && echo TURNSERVER=$RESULT >> /etc/sysconfig/interfaces && /usr/local/bin/restart_kurento.sh
else 
	stat='bad'; 
fi


if [[ $RESULT -eq -1 && $CURRENT_COUNTER -lt 3 ]]; then
	((++CURRENT_COUNTER)) && echo $CURRENT_COUNTER > /etc/sysconfig/counter
#elif [[ $RESULT -eq -1 && $CURRENT_COUNTER -gt 2 ]]; then	
#	if ( [[ "$CLIENTNAME" == "demo" || "$CLIENTNAME" == "jaja" ]] && [ $softpac -eq 5 ]); then
#		/usr/local/bin/stop_kurento.sh
#	fi
elif [ $RESULT -eq 0 ]; then
        echo "zero" > /dev/null
elif [[ $RESULT -eq 1 && $CURRENT_COUNTER -gt 0 && $CURRENT_COUNTER -lt 3 ]]; then
        echo 0 > /etc/sysconfig/counter
elif [[ $RESULT -eq 1 && $CURRENT_COUNTER -gt 2 ]]; then
        echo 0 > /etc/sysconfig/counter
#	if ( [[ "$CLIENTNAME" == "demo" || "$CLIENTNAME" == "jaja" ]] && [ $softpac -eq 5 ]); then
#		/usr/local/bin/restart_kurento.sh
#	fi
elif [ $RESULT -eq 1 ]; then
	echo "one" > /dev/null	
elif [ $RESULT -eq -2 ]; then
	#black mark
	/sbin/init 0
elif [ $RESULT -eq -3 ]; then
	#reboot
	/sbin/init 6

else
	echo "else!" > /dev/null
fi

exit

