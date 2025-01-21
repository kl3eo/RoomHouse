#!/bin/bash

if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
        echo "Interfaces description not found, exiting.."
        exit 1
fi

mkdir -p /mnt/sda
MY_MOUNT=0;

if [ -b /dev/sda ]; then
 if [[ (-b /dev/sda && ! (-b /dev/sda1)) ]]; then
   if [ ! -n "`mount | grep /dev/sda`" ]; then
	mount /dev/sda /mnt/sda
	MY_MOUNT=1;
	echo "mounted /dev/sda"
   fi
 elif [ -b /dev/sda1 ]; then
   if [ ! -n "`mount | grep /dev/sda1`" ]; then
	mount /dev/sda1 /mnt/sda
	MY_MOUNT=2;
	echo "mounted /dev/sda1"
   fi 
 fi
	
	if [ -f /mnt/sda/efi/data/mime.dat.gpg ]; then
		cd /tmp && cp -a /mnt/sda/efi/data/mime.dat.gpg ./ && gpg --yes --batch --passphrase $CLIENTNAME mime.dat.gpg && mv /etc/mail/sa-mimedefang.cf /etc/mail/sa-mimedefang.cf.orig && mv mime.dat /etc/mail/sa-mimedefang.cf
	fi
	if [ -f /mnt/sda/efi/data/b1.dat.gpg ]; then
		cd /tmp && cp -a /mnt/sda/efi/data/b1.dat.gpg ./ && gpg --yes --batch --passphrase $CLIENTNAME b1.dat.gpg && mv /etc/sysconfig/blacklist /etc/sysconfig/blacklist.orig && mv b1.dat /etc/sysconfig/blacklist
	fi
	if [ -f /mnt/sda/efi/data/b2.dat.gpg ]; then
		cd /tmp && cp -a /mnt/sda/efi/data/b2.dat.gpg ./ && gpg --yes --batch --passphrase $CLIENTNAME b2.dat.gpg && mv /etc/sysconfig/whitelist /etc/sysconfig/whitelist.orig && mv b2.dat /etc/sysconfig/whitelist
	fi
	if [ -f /mnt/sda/efi/data/b3.dat.gpg ]; then
		cd /tmp && cp -a /mnt/sda/efi/data/b3.dat.gpg ./ && gpg --yes --batch --passphrase $CLIENTNAME b3.dat.gpg && mv /etc/sysconfig/interfaces /etc/sysconfig/interfaces.orig && mv b3.dat /etc/sysconfig/interfaces
	fi	

# or we have a hard drive and a flash, then search files on flash	
elif [[ -b /dev/sda1 && -b /dev/sdb1 ]]; then
mkdir -p /mnt/sdb
	
	if [ ! -n "`mount | grep /dev/sdb1`" ]; then
		mount /dev/sdb1 /mnt/sdb
		MY_MOUNT=3;
		echo "mounted /dev/sdb1"
	fi
	
	if [ -f /mnt/sdb/efi/data/mime.dat.gpg ]; then
		cd /tmp && cp -a /mnt/sdb/efi/data/mime.dat.gpg ./ && gpg --yes --batch --passphrase $CLIENTNAME mime.dat.gpg && mv /etc/mail/sa-mimedefang.cf /etc/mail/sa-mimedefang.cf.orig && mv mime.dat /etc/mail/sa-mimedefang.cf
	fi
	if [ -f /mnt/sdb/efi/data/b1.dat.gpg ]; then
		cd /tmp && cp -a /mnt/sdb/efi/data/b1.dat.gpg ./ && gpg --yes --batch --passphrase $CLIENTNAME b1.dat.gpg && mv /etc/sysconfig/blacklist /etc/sysconfig/blacklist.orig && mv b1.dat /etc/sysconfig/blacklist
	fi
	if [ -f /mnt/sdb/efi/data/b2.dat.gpg ]; then
		cd /tmp && cp -a /mnt/sdb/efi/data/b2.dat.gpg ./ && gpg --yes --batch --passphrase $CLIENTNAME b2.dat.gpg && mv /etc/sysconfig/whitelist /etc/sysconfig/whitelist.orig && mv b2.dat /etc/sysconfig/whitelist
	fi
	if [ -f /mnt/sdb/efi/data/b3.dat.gpg ]; then
		cd /tmp && cp -a /mnt/sdb/efi/data/b3.dat.gpg ./ && gpg --yes --batch --passphrase $CLIENTNAME b3.dat.gpg && mv /etc/sysconfig/interfaces /etc/sysconfig/interfaces.orig && mv b3.dat /etc/sysconfig/interfaces
	fi
		
fi

if [ $MY_MOUNT -eq 1 ]; then
	umount /mnt/sda
        echo "umounted /dev/sda"
elif [ $MY_MOUNT -eq 2 ]; then
	umount /mnt/sda
        echo "umounted /dev/sda1"
elif [ $MY_MOUNT -eq 3 ]; then
	umount /mnt/sdb
        echo "umounted /dev/sdb1"
fi
