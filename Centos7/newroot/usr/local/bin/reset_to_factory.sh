#!/bin/bash
mkdir -p /mnt/sda
MY_MOUNT=0;

rm -f /etc/sysconfig/interfaces.saved

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
	
	if [ -f /mnt/sda/efi/etc/sysconfig/interfaces.good ]; then
		echo "changing interfaces with GOOD on /dev/sda1:\n"
		cp -af /mnt/sda/efi/etc/sysconfig/interfaces.good /mnt/sda/efi/etc/sysconfig/interfaces
		cp -f /mnt/sda/efi/etc/sysconfig/interfaces /etc/sysconfig/ifaces.img
		zcat /etc/sysconfig/ifaces.img | cpio -idmv
		mv /etc/sysconfig/ifaces /etc/sysconfig/interfaces
		rm -f /root/iptables.sh
		ln -s /root/iptables_bl.sh /root/iptables.sh
		/root/iptables.sh
		
		echo "changed interfaces to GOOD successfully"
	fi
	if [ -f /mnt/sda/efi/etc/sysconfig/blacklist ]; then
		rm -f /mnt/sda/efi/etc/sysconfig/blacklist
		rm -f /etc/sysconfig/blacklist
		
		echo "deleted saved blacklist successfully"
	fi
	if [ -f /mnt/sda/efi/etc/sysconfig/whitelist ]; then
		rm -f /mnt/sda/efi/etc/sysconfig/whitelist
		rm -f /etc/sysconfig/whitelist
		
		echo "deleted saved whitelist successfully"
	fi
	
# or we have a hard drive and a flash, then search files on flash	
elif [[ -b /dev/sda1 && -b /dev/sdb1 ]]; then
	
   if [ ! -n "`mount | grep /dev/sdb1`" ]; then
        mount /dev/sdb1 /mnt/sdb
        MY_MOUNT=3;
        echo "mounted /dev/sdb1"
   fi
   
	if [ -f /mnt/sdb/efi/etc/sysconfig/interfaces.good ]; then
		echo "changing interfaces with GOOD on /dev/sdb1:\n"
		cp -af /mnt/sdb/efi/etc/sysconfig/interfaces.good /mnt/sdb/efi/etc/sysconfig/interfaces
		cp -f /mnt/sdb/efi/etc/sysconfig/interfaces /etc/sysconfig/ifaces.img
		zcat /etc/sysconfig/ifaces.img | cpio -idmv
		mv /etc/sysconfig/ifaces /etc/sysconfig/interfaces
		
		echo "changed interfaces to GOOD successfully"
	fi
	if [ -f /mnt/sdb/efi/etc/sysconfig/blacklist ]; then
		rm -f /mnt/sdb/efi/etc/sysconfig/blacklist
		rm -f /etc/sysconfig/blacklist
		
		echo "deleted saved blacklist successfully"
	fi
	if [ -f /mnt/sdb/efi/etc/sysconfig/whitelist ]; then
		rm -f /mnt/sdb/efi/etc/sysconfig/whitelist
		rm -f /etc/sysconfig/whitelist
		
		echo "deleted saved whitelist successfully"
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
