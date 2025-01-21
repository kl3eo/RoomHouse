#!/bin/bash

if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
        echo "Interfaces description not found, exiting.."
        exit 1
fi

MY_MOUNT=0;

OLDXPASS=`cat /etc/sysconfig/interfaces | grep KEY2 | awk -F '=' '{print $2}'`
CURRXPASS=`cat /etc/sysconfig/interfaces.new| grep KEY2 | awk -F '=' '{print $2}'`

OLDWPASS=`cat /etc/sysconfig/interfaces | grep KEY1 | awk -F '=' '{print $2}'`
CURRWPASS=`cat /etc/sysconfig/interfaces.new| grep KEY1 | awk -F '=' '{print $2}'`

rm -f /etc/sysconfig/interfaces.saved && cp -a /etc/sysconfig/interfaces.new /etc/sysconfig/interfaces.saved

FLASH_A=false
FLASH_B=false
FLASH_C=false

mkdir -p /mnt/sda/
mkdir -p /mnt/sdb/
mkdir -p /mnt/sdc/

if [[ (-b /dev/sda && ! (-b /dev/sda1)) ]]; then
	if [ ! -n "`mount | grep /dev/sda`" ]; then
		mount /dev/sda /mnt/sda
		MY_MOUNT=1
		echo "mounted /dev/sda"
	fi
	if [ -d /mnt/sda/efi/etc ]; then
		FLASH_A=true	
	else
		echo "mounted sda and no /mnt/sda/efi/etc"
		if [ $MY_MOUNT -eq 1 ]; then
			umount /mnt/sda
		fi		
	fi
elif [ -b /dev/sda1 ]; then
	if [ ! -n "`mount | grep /dev/sda1`" ]; then
		mount /dev/sda1 /mnt/sda
		MY_MOUNT=2
		echo "mounted /dev/sda1"
	fi 
	if [ -d /mnt/sda/efi/etc ]; then
		FLASH_A=true	
	else
		echo "mounted sda1 and no /mnt/sda/efi/etcg"
		if [ $MY_MOUNT -eq 2 ]; then
			umount /mnt/sda
		fi		
	fi
fi

if [[ (-b /dev/sdb && ! (-b /dev/sdb1) && ! ($FLASH_A == true)) ]]; then
	if [ ! -n "`mount | grep /dev/sdb`" ]; then
		mount /dev/sdb /mnt/sdb
		MY_MOUNT=3
		echo "mounted /dev/sdb"
	fi
	if [ -d /mnt/sdb/efi/etc ]; then
		FLASH_B=true	
	else
		echo "mounted sdb and no /mnt/sdb/efi/etc"
		if [ $MY_MOUNT -eq 3 ]; then
			umount /mnt/sdb
		fi		
	fi
elif [[ (-b /dev/sdb1  && ! ($FLASH_A == true)) ]]; then
	if [ ! -n "`mount | grep /dev/sdb1`" ]; then
		mount /dev/sdb1 /mnt/sdb
		MY_MOUNT=4
		echo "mounted /dev/sdb1"
	fi 
	if [ -d /mnt/sdb/efi/etc ]; then
		FLASH_B=true	
	else
		echo "mounted sdb1 and no /mnt/sdb/efi/etc"
		if [ $MY_MOUNT -eq 4 ]; then
			umount /mnt/sdb
		fi		
	fi
fi

if [[ (-b /dev/sdc && ! (-b /dev/sdc1) && ! ($FLASH_A == true) && ! ($FLASH_B == true)) ]]; then
	if [ ! -n "`mount | grep /dev/sdc`" ]; then
		mount /dev/sdc /mnt/sdc
		MY_MOUNT=5
		echo "mounted /dev/sdc"		
	fi
	if [ -d /mnt/sdc/efi/etc ]; then
		FLASH_C=true	
	else
		echo "mounted sdc and no /mnt/sdc/efi/etc"
		if [ $MY_MOUNT -eq 5 ]; then
			umount /mnt/sdc
		fi		
	fi	
elif [[ (-b /dev/sdc1 && ! ($FLASH_A == true) && ! ($FLASH_B == true)) ]]; then
	if [ ! -n "`mount | grep /dev/sdc1`" ]; then
		mount /dev/sdc1 /mnt/sdc
		MY_MOUNT=6
		echo "mounted /dev/sdc1"
	fi 
	if [ -d /mnt/sdc/efi/etc ]; then
		FLASH_C=true	
	else
		echo "mounted sdc1 and no /mnt/sdc/efi/etc"
		if [ $MY_MOUNT -eq 6 ]; then
			umount /mnt/sdc
		fi		
	fi
fi

echo mount is $MY_MOUNT

if [ $FLASH_A == true ]; then

	if [ -d /mnt/sda/efi/etc ]; then
	   if [ -f /etc/sysconfig/interfaces.new ]; then
		echo "changing interfaces with new on /dev/sda1:\n"	
		#OLD WAYS REMOVED
		#mkdir -p /mnt/sda/efi/etc/sysconfig
		#mv /etc/sysconfig/interfaces.new /etc/sysconfig/ifaces
		#find /etc/sysconfig/ifaces -print0 | cpio --null -ov --format=newc | gzip -9 > /etc/sysconfig/ifaces.img
		#mv /etc/sysconfig/ifaces.img /mnt/sda/efi/etc/sysconfig/interfaces

		cat /etc/sysconfig/interfaces.saved | gpg --yes --batch --passphrase=$CLIENTNAME -c - > /mnt/sda/efi/data/b3.dat.gpg

		
		echo "changed interfaces with new successfully"
	   fi
	fi
	
	if [ -d /mnt/sda/efi/etc ]; then
		echo "changing blacklist with new on /dev/sda1:\n"
		#OLD WAYS REMOVED
		#mkdir -p /mnt/sda/efi/etc/sysconfig
		#cp -a /etc/sysconfig/blacklist /etc/sysconfig/blist
		#find /etc/sysconfig/blist -print0 | cpio --null -ov --format=newc | gzip -9 > /etc/sysconfig/blist.img
		#mv /etc/sysconfig/blist.img /mnt/sda/efi/etc/sysconfig/blacklist

		cat /etc/sysconfig/blacklist | gpg --yes --batch --passphrase=$CLIENTNAME -c - > /mnt/sda/efi/data/b1.dat.gpg

		echo "changed blacklist with new successfully"
		
		echo "changing whitelist with new on /dev/sda1:\n"
		#OLD WAYS REMOVED
		#cp -a /etc/sysconfig/whitelist /etc/sysconfig/wlist
		#find /etc/sysconfig/wlist -print0 | cpio --null -ov --format=newc | gzip -9 > /etc/sysconfig/wlist.img
		#mv /etc/sysconfig/wlist.img /mnt/sda/efi/etc/sysconfig/whitelist

		cat /etc/sysconfig/whitelist | gpg --yes --batch --passphrase=$CLIENTNAME -c - > /mnt/sda/efi/data/b2.dat.gpg

		echo "changed whitelist with new successfully"
	fi
	
elif [ $FLASH_B == true ]; then
	
	if [ -d /mnt/sdb/efi/etc ]; then
	   if [ -f /etc/sysconfig/interfaces.new ]; then
                echo "changing interfaces with new on /dev/sdb1:\n"
		#OLD WAYS REMOVED
		#mkdir -p /mnt/sdb/efi/etc/sysconfig
		#mv /etc/sysconfig/interfaces.new /etc/sysconfig/ifaces
		#find /etc/sysconfig/ifaces -print0 | cpio --null -ov --format=newc | gzip -9 > /etc/sysconfig/ifaces.img
		#mv /etc/sysconfig/ifaces.img /mnt/sdb/efi/etc/sysconfig/interfaces

		cat /etc/sysconfig/interfaces.saved | gpg --yes --batch --passphrase=$CLIENTNAME -c - > /mnt/sdb/efi/data/b3.dat.gpg
		
                echo "changed interfaces with new successfully"
           fi
	fi
	if [ -d /mnt/sdb/efi/etc ]; then
		echo "changing blacklist with new on /dev/sdb1:\n"
		#OLD WAYS REMOVED
		#mkdir -p /mnt/sdb/efi/etc/sysconfig
		#cp -a /etc/sysconfig/blacklist /etc/sysconfig/blist
		#find /etc/sysconfig/blist -print0 | cpio --null -ov --format=newc | gzip -9 > /etc/sysconfig/blist.img
		#mv /etc/sysconfig/blist.img /mnt/sdb/efi/etc/sysconfig/blacklist

		cat /etc/sysconfig/blacklist | gpg --yes --batch --passphrase=$CLIENTNAME -c - > /mnt/sdb/efi/data/b1.dat.gpg

		echo "changed blacklist with new successfully"
		
		echo "changing whitelist with new on /dev/sdb1:\n"
		#OLD WAYS REMOVED
		#cp -a /etc/sysconfig/whitelist /etc/sysconfig/wlist
		#find /etc/sysconfig/wlist -print0 | cpio --null -ov --format=newc | gzip -9 > /etc/sysconfig/wlist.img
		#mv /etc/sysconfig/wlist.img /mnt/sdb/efi/etc/sysconfig/whitelist

		cat /etc/sysconfig/whitelist | gpg --yes --batch --passphrase=$CLIENTNAME -c - > /mnt/sdb/efi/data/b2.dat.gpg

		echo "changed whitelist with new successfully"
	fi	
elif [ $FLASH_C == true ]; then
	
	if [ -d /mnt/sdc/efi/etc ]; then
	   if [ -f /etc/sysconfig/interfaces.new ]; then
                echo "changing interfaces with new on /dev/sdc1:\n"
		#OLD WAYS REMOVED
		#mkdir -p /mnt/sdc/efi/etc/sysconfig
		#mv /etc/sysconfig/interfaces.new /etc/sysconfig/ifaces
		#find /etc/sysconfig/ifaces -print0 | cpio --null -ov --format=newc | gzip -9 > /etc/sysconfig/ifaces.img
		#mv /etc/sysconfig/ifaces.img /mnt/sdc/efi/etc/sysconfig/interfaces

		cat /etc/sysconfig/interfaces.saved | gpg --yes --batch --passphrase=$CLIENTNAME -c - > /mnt/sdc/efi/data/b3.dat.gpg
		
                echo "changed interfaces with new successfully"
           fi
	fi
	if [ -d /mnt/sdc/efi/etc ]; then
		echo "changing blacklist with new on /dev/sdc1:\n"
		#OLD WAYS REMOVED
		#mkdir -p /mnt/sdc/efi/etc/sysconfig
		#cp -a /etc/sysconfig/blacklist /etc/sysconfig/blist
		#find /etc/sysconfig/blist -print0 | cpio --null -ov --format=newc | gzip -9 > /etc/sysconfig/blist.img
		#mv /etc/sysconfig/blist.img /mnt/sdc/efi/etc/sysconfig/blacklist

		cat /etc/sysconfig/blacklist | gpg --yes --batch --passphrase=$CLIENTNAME -c - > /mnt/sdc/efi/data/b1.dat.gpg

		echo "changed blacklist with new successfully"
		
		echo "changing whitelist with new on /dev/sdc1:\n"
		#OLD WAYS REMOVED
		#cp -a /etc/sysconfig/whitelist /etc/sysconfig/wlist
		#find /etc/sysconfig/wlist -print0 | cpio --null -ov --format=newc | gzip -9 > /etc/sysconfig/wlist.img
		#mv /etc/sysconfig/wlist.img /mnt/sdc/efi/etc/sysconfig/whitelist

		cat /etc/sysconfig/whitelist | gpg --yes --batch --passphrase=$CLIENTNAME -c - > /mnt/sdc/efi/data/b2.dat.gpg

		echo "changed whitelist with new successfully"
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
        echo "umounted /dev/sdb"
elif [ $MY_MOUNT -eq 4 ]; then
	umount /mnt/sdb
        echo "umounted /dev/sdb1"
elif [ $MY_MOUNT -eq 5 ]; then
	umount /mnt/sdc
        echo "umounted /dev/sdc"
elif [ $MY_MOUNT -eq 6 ]; then
	umount /mnt/sdc
        echo "umounted /dev/sdc1"
fi


if [ "$OLDXPASS" != "$CURRXPASS" ]; then

XPPASS=`/usr/local/bin/chip8.sh $CURRXPASS`
/var/www/html/cp/controls/removeUser.pl admin && /var/www/html/cp/controls/addUser.pl admin $XPPASS a\@b.com

fi

if [ "$OLDWPASS" != "$CURRWPASS" ]; then


# -- this is done in change_val.sh
#CURRWPASS=`cat /etc/sysconfig/interfaces.saved | grep KEY1 | awk -F '=' '{print $2}'`
#WIFIPASS=`/usr/local/bin/chip8.sh $CURRWPASS`
#sed -i "s/wpa_passphrase=.*/wpa_passphrase=$WIFIPASS/g" /etc/hostapd/hostapd.conf

service hostapd restart
fi

cp -a /etc/sysconfig/interfaces.saved /etc/sysconfig/interfaces
