#!/bin/bash

H=`dmesg | grep Hyper | awk '{print $3}'`
SOFTPAC=`cat /etc/sysconfig/softpac`

if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
	echo "Interfaces description not found, exiting.."
	exit 1
fi

LOW=false
if ([[ "$CLIENTNAME" == "demo" || "$CLIENTNAME" == "jaja" || "$CLIENTNAME" == "rhplus" || $SOFTPAC -eq 7 ]]); then
	LOW=true
fi

if ([[ "$HOSTNAME" == "corfu" || "$HOSTNAME" == "sorba" || "$HOSTNAME" == "marta" ]]); then
	cipher="serpent"
else
	cipher="anubis"
fi

#faketty () { script -qfc "$(printf "%q " "$@")"; }
ssd=0

if [ -b /dev/sda1 ]; then

	SIZE1=`/usr/sbin/blockdev --getsize64 /dev/sda1`
	HSIZE1=$(($SIZE1*2))

else
	HSIZE1=0
fi

if [ -b /dev/sda2 ]; then
	SIZE2=`/usr/sbin/blockdev --getsize64 /dev/sda2`
	HSIZE2=$(($SIZE2*2))

else
	HSIZE2=0
fi


if [ -b /dev/nvme0n1p1 ]; then

	ssd=1

	#already mounted in check_ssd.sh
	s=`df | grep "/dev/nvme0n1p1" | awk '{print int(($4/(1024*1024)) * 0.5)}'`;	
	
elif [[ -b /dev/sda1 && $(($HSIZE1-8000000000)) -gt 0 ]]; then

	ssd=1
	s=`df | grep "/dev/sda1" | awk '{print int(($4/(1024*1024)) * 0.5)}'`;
	
	#hack ash - we need this /opt/nvme/ in many scripts already
	mkdir -p /opt/nvme && mount /dev/sda1 /opt/nvme
	mkdir -p /opt/nvme/ssd	

elif [[ -b /dev/sda2 && $(($HSIZE2-8000000000)) -gt 0 ]]; then

	ssd=1
	s=`df | grep "/dev/sda2" | awk '{print int(($4/(1024*1024)) * 0.5)}'`;
	
	#hack ash - we need this /opt/nvme/ in many scripts already
	mkdir -p /opt/nvme && mount /dev/sda2 /opt/nvme
	mkdir -p /opt/nvme/ssd	


elif [ -b /dev/sdb1 ]; then
	
	ssd=1
	s=`df | grep "/dev/sdb1" | awk '{print int(($4/(1024*1024)) * 0.5)}'`;
	
	#hack ash - we need this /opt/nvme/ in many scripts already
	mkdir -p /opt/nvme && mount /dev/sdb1 /opt/nvme
	mkdir -p /opt/nvme/ssd	
	#hack#2 - we need this for the first boot of VM
	H=`dmesg | grep Hyper | awk '{print $3}'`
	if [ ! -n "`mount | grep /dev/sdb1 | grep -v nvme`" ]; then
	   if [ $H == 'Hypervisor' ]; then
		mkdir -p /mnt/sda && mount /dev/sdb1 /mnt/sda
	   fi
        fi
 
else
	#everything goes into RAM
	echo shit
	mkdir -p /opt/nvme/ssd
fi


if [ "$ssd" == 1 ]; then
        if ([[ ! -f /opt/nvme/ssd.img || ! -s /opt/nvme/ssd.img ]]); then
                #we don't want a lot of encrypted space? save time then, 1G is all we need free space for DB, logs, etc.
                rm -f /opt/nvme/ssd.img
                if [[ $s > 1 && $LOW ]]; then
                        s=1
                fi
                if [[ $s == 0 && $LOW ]]; then
                        s=0.5
                fi

                if ([[ $s > 1 || $s == 1 ]]); then
                        dd if=/dev/zero of=/opt/nvme/ssd.img bs=1G count=$s
                else
                        #dd if=/dev/zero of=/opt/nvme/ssd.img bs=1M count=512 #not enough!
			dd if=/dev/zero of=/opt/nvme/ssd.img bs=1G count=1
                fi
		
		echo $CLIENTNAME | /usr/bin/cryptsetup --hash sha256 --cipher $cipher --key-size 256 open --type plain /opt/nvme/ssd.img ssd
		/usr/sbin/mkfs.ext4 -j /dev/mapper/ssd && mkdir -p /opt/nvme/ssd && mount /dev/mapper/ssd /opt/nvme/ssd
	else
		echo $CLIENTNAME | /usr/bin/cryptsetup --hash sha256 --cipher $cipher --key-size 256 open --type plain /opt/nvme/ssd.img ssd
		mkdir -p /opt/nvme/ssd && mount /dev/mapper/ssd /opt/nvme/ssd	
	fi
fi

#pg_data
if [ -d /opt/nvme/data/ ]; then
	mkdir -p /opt/nvme/ssd
	mv /opt/nvme/data /opt/nvme/ssd/
fi

cp -a /root/pg_data_stub /root/pg_data_stub_res

if [ ! -d /opt/nvme/ssd/data/ ]; then
	 rm -rf /opt/nvme/ssd/data && mv /root/pg_data_stub /opt/nvme/ssd/data	
else
	rm -rf /root/pg_data_stub
fi

rm -rf /opt/nvme/data && ln -s /opt/nvme/ssd/data /opt/nvme/data
chown -R postgres:postgres /opt/nvme/data/
chown -R postgres:postgres /opt/nvme/ssd/data/
chown -R postgres:postgres /usr/local/pgsql/data/

#var
mkdir -p /opt/nvme/var/
#DO NOT log to ssd or you cannot umount
#if [ ! -d /opt/nvme/ssd/var/ ]; then
#        rm -rf /opt/nvme/ssd/var && mv /opt/nvme/var/ /opt/nvme/ssd/
#	mkdir -p /opt/nvme/ssd/var/
#else
#	rm -rf /opt/nvme/var
#fi
#ln -s /opt/nvme/ssd/var/ /opt/nvme/var

#videos
mkdir -p /opt/nvme/videos/ && chown -R nobody:nobody /opt/nvme/videos

if [ ! -d /opt/nvme/ssd/videos/ ]; then
        rm -rf /opt/nvme/ssd/videos && mv /opt/nvme/videos/ /opt/nvme/ssd/
	mkdir -p /opt/nvme/ssd/videos/
else
	rm -rf /opt/nvme/videos && chown -R nobody /opt/nvme/ssd/videos/
fi
ln -s /opt/nvme/ssd/videos/ /opt/nvme/videos

#vmail_store
mkdir -p /opt/nvme/vmail_store/ && chown -R nobody:nobody /opt/nvme/vmail_store

if [ ! -d /opt/nvme/ssd/vmail_store/ ]; then
        rm -rf /opt/nvme/ssd/vmail_store && mv /opt/nvme/vmail_store/ /opt/nvme/ssd/
	mkdir -p /opt/nvme/ssd/vmail_store/
else
	rm -rf /opt/nvme/vmail_store && chown -R nobody /opt/nvme/ssd/vmail_store/
fi
ln -s /opt/nvme/ssd/vmail_store/ /opt/nvme/vmail_store

#logs
mkdir -p /opt/nvme/logs/
if [ ! -d /opt/nvme/ssd/logs/ ]; then
        rm -rf /opt/nvme/ssd/logs && mv /opt/nvme/logs/ /opt/nvme/ssd/
	mkdir -p /opt/nvme/ssd/logs/
else
	rm -rf /opt/nvme/logs
fi
ln -s /opt/nvme/ssd/logs/ /opt/nvme/logs
 
#upload
mkdir -p /opt/nvme/upload/ && chown -R apache:apache /opt/nvme/upload
if [ ! -d /opt/nvme/ssd/upload/ ]; then
        rm -rf /opt/nvme/ssd/upload && mv /opt/nvme/upload/ /opt/nvme/ssd/
	mkdir -p /opt/nvme/ssd/upload/
else
	rm -rf /opt/nvme/upload
fi
chown -R apache:apache /opt/nvme/ssd/upload && ln -s /opt/nvme/ssd/upload/ /opt/nvme/upload

#home/nobody
mkdir -p /opt/nvme/home/nobody/ && chown -R nobody:nobody /opt/nvme/home/nobody && chmod 750 /opt/nvme/home/nobody
if [ ! -d /opt/nvme/ssd/nobody/ ]; then
        rm -rf /opt/nvme/ssd/nobody && mv /opt/nvme/home/nobody/ /opt/nvme/ssd/
	mkdir -p /opt/nvme/ssd/nobody/
else
	rm -rf /opt/nvme/home/nobody && chown -R nobody:nobody /opt/nvme/ssd/nobody/
fi
ln -s /opt/nvme/ssd/nobody/ /opt/nvme/home/nobody

#home/op == after doing this won't be working with "op" remotely; fix chroot issues otherwise like:
#[root@iron ~]# chmod 755 /opt/nvme/ssd/op
#[root@iron ~]# chown root:root /opt/nvme/ssd/op

mkdir -p /opt/nvme/home/op && chown -R op:op /opt/nvme/home/op
rm -rf /opt/nvme/ssd/op && mv /opt/nvme/home/op/ /opt/nvme/ssd/ && ln -s /opt/nvme/ssd/op/ /opt/nvme/home/op

#home/postgres
mkdir -p /opt/nvme/home/postgres && chown -R postgres:postgres /opt/nvme/home/postgres
if [ ! -d /opt/nvme/ssd/postgres/ ]; then
        rm -rf /opt/nvme/ssd/postgres && mv /opt/nvme/home/postgres/ /opt/nvme/ssd/
else
	rm -rf /opt/nvme/home/postgres && chown -R postgres:postgres /opt/nvme/ssd/postgres/
fi
ln -s /opt/nvme/ssd/postgres/ /opt/nvme/home/postgres

#save log.html
if [ ! -f /opt/nvme/ssd/nobody/log.html ]; then
	mkdir -p /opt/nvme/ssd/nobody/ && rm -f /opt/nvme/ssd/nobody/log.html && mv /var/www/html/cp/public_html/log.html /opt/nvme/ssd/nobody/ && chown -R nobody:nobody /opt/nvme/ssd/nobody/
else
	rm -f /var/www/html/cp/public_html/log.html
fi
ln -s /opt/nvme/ssd/nobody/log.html /var/www/html/cp/public_html/
