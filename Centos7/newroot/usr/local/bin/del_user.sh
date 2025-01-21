#!/bin/bash

if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
        echo "Interfaces description not found, exiting.."
        exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "USAGE: ./del.sh USER" && exit
fi

USER=$1
USERID=`id -u $USER`

if [ $(($USERID-1002)) -gt 0 ]; then

saslpasswd2 -f /etc/sasldb2 -d $USER

cyradm -U cyrus -w $CLIENTNAME localhost << SCRIPT
sam user.$USER cyrus all
dm user.$USER
SCRIPT

userdel -r $USER

mkdir -p /mnt/sda

MY_MOUNT=0;

if [[ (-b /dev/sda1 && ! (-b /dev/sdb1)) ]]; then
   if [ ! -n "`mount | grep /dev/sda1`" ]; then
	mount /dev/sda1 /mnt/sda
	MY_MOUNT=1;
	echo "mounted /dev/sda1"
   fi
	mkdir -p /mnt/sda/efi/data/
	if [ -d /mnt/sda/efi/data/ ]; then
		sed -n '38,$ p' /etc/passwd | gpg --yes --batch --passphrase=$CLIENTNAME -c - > /mnt/sda/efi/data/u1.dat.gpg
		sed -n '38,$ p' /etc/shadow | gpg --yes --batch --passphrase=$CLIENTNAME -c - > /mnt/sda/efi/data/u2.dat.gpg
		sed -n '62,$ p' /etc/group | gpg --yes --batch --passphrase=$CLIENTNAME -c - > /mnt/sda/efi/data/g.dat.gpg
		cd /tmp && cp -a /etc/sasldb2 ./ && gpg --yes --batch --passphrase=$CLIENTNAME -c sasldb2 && rm -f sasldb2 && mv sasldb2.gpg /mnt/sda/efi/data/
	fi

# or we have a hard drive and a flash, then search files on flash	
elif [[ -b /dev/sda1 && -b /dev/sdb1 ]]; then
	mkdir -p /mnt/sdb	
	if [ ! -n "`mount | grep /dev/sdb1`" ]; then
		mount /dev/sdb1 /mnt/sdb
		MY_MOUNT=2;
		echo "mounted /dev/sdb1"
	fi
	
	mkdir -p /mnt/sdb/efi/data/
	if [ -d /mnt/sdb/efi/data/ ]; then
		sed -n '38,$ p' /etc/passwd | gpg --yes --batch --passphrase=$CLIENTNAME -c - > /mnt/sdb/efi/data/u1.dat.gpg
		sed -n '38,$ p' /etc/shadow | gpg --yes --batch --passphrase=$CLIENTNAME -c - > /mnt/sdb/efi/data/u2.dat.gpg
		sed -n '62,$ p' /etc/group | gpg --yes --batch --passphrase=$CLIENTNAME -c - > /mnt/sdb/efi/data/g.dat.gpg
		cd /tmp && cp -a /etc/sasldb2 ./ && gpg --yes --batch --passphrase=$CLIENTNAME -c sasldb2 && rm -f sasldb2 && mv sasldb2.gpg /mnt/sdb/efi/data/
	fi
fi

if [ $MY_MOUNT -eq 1 ]; then
	umount /mnt/sda
        echo "umounted /dev/sda1"
elif [ $MY_MOUNT -eq 2 ]; then
	umount /mnt/sdb
        echo "umounted /dev/sdb1"
fi

fi
