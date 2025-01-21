#!/bin/bash
mkdir -p /mnt/sda
MY_MOUNT=0;

if [[ (-b /dev/sda1 && ! (-b /dev/sdb1) && ! (-b /dev/sdc1)) ]]; then
   if [ ! -n "`mount | grep /dev/sda1`" ]; then
	mount /dev/sda1 /mnt/sda
	MY_MOUNT=1;

   fi
	
# or we have a hard drive and a flash	
elif [[ (-b /dev/sda1 && -b /dev/sdb1 && ! (-b /dev/sdc1)) ]]; then
mkdir -p /mnt/sdb	
   if [ ! -n "`mount | grep /dev/sdb1`" ]; then
        mount /dev/sdb1 /mnt/sdb
        MY_MOUNT=2;
   fi

elif [[ (-b /dev/sda1 && ! (-b /dev/sdb1) && -b /dev/sdc1) ]]; then
mkdir -p /mnt/sdb	
   if [ ! -n "`mount | grep /dev/sdc1`" ]; then
        umount -f /mnt/sdb 
	mount /dev/sdc1 /mnt/sdb
        MY_MOUNT=2;
   fi
	
fi

mkdir -p /opt/nvme/iso && chown -R nobody /opt/nvme/iso/

echo $MY_MOUNT
exit
