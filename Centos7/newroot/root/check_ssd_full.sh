#!/bin/bash

H=`dmesg | grep Hyper | awk '{print $3}'`

if [[ (-b /dev/nvme0n1 && ! (-b /dev/nvme0n1p1)) ]]; then

#	SIZE=`/sbin/sfdisk -s /dev/nvme0n1`
#	HSIZE=$(($SIZE*2))
#check if size  > 100GB,  probably an SSD drive
#if [ $(($HSIZE-200000000)) -gt 0 ]; then
#	DSI=$(($HSIZE-2048))
#	echo $DSI
#	sed -i "s|size=488395120|size=$DSI|g" /root/nvme0n1.out
#	/sbin/sfdisk /dev/nvme0n1 < /root/nvme0n1.out

	echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/nvme0n1
	/sbin/mkfs.ext4 /dev/nvme0n1p1
	mkdir -p /opt/nvme && mount /dev/nvme0n1p1 /opt/nvme

	service sendmail stop
	service cyrus-imapd stop
	service clamav-milter stop
	service mimedefang stop
	service spamassassin stop

	mv /home/ /opt/nvme/
	ln -s /opt/nvme/home /home
	
	mv /var/www/html/cp/public_html/videos/ /opt/nvme/
	ln -s /opt/nvme/videos/ /var/www/html/cp/public_html/

	mkdir -p /opt/nvme/var/

	mv /var/log/ /opt/nvme/var/
	ln -s /opt/nvme/var/log /var/log
	
	mkdir -p /opt/nvme/var/www/html/cp/public_html/tmp/
	mv /var/www/html/cp/public_html/tmp/db_images/ /opt/nvme/var/www/html/cp/public_html/tmp/
	ln -s /opt/nvme/var/www/html/cp/public_html/tmp/db_images/ /var/www/html/cp/public_html/tmp/
	
	mkdir -p /opt/nvme/var/www/html/lightsquid/
	mv /var/www/html/lightsquid/report/ /opt/nvme/var/www/html/lightsquid/
	ln -s /opt/nvme/var/www/html/lightsquid/report/ /var/www/html/lightsquid/

	mkdir -p /opt/nvme/var/www/html/
	mv /home/op/mysite/ /opt/nvme/var/www/html/
	ln -s /opt/nvme/var/www/html/mysite/ /home/op/
			
	mkdir -p /opt/nvme/var/spool/
	mv /var/spool/mail/ /opt/nvme/var/spool/
	ln -s /opt/nvme/var/spool/mail/ /var/spool/

	mv /var/spool/imap/ /opt/nvme/var/spool/
	ln -s /opt/nvme/var/spool/imap/ /var/spool/

	mkdir -p /opt/nvme/var/lib/
	mv /var/lib/imap/ /opt/nvme/var/lib/
	ln -s /opt/nvme/var/lib/imap/ /var/lib/

	mv /var/lib/clamav/ /opt/nvme/var/lib/
	ln -s /opt/nvme/var/lib/clamav/ /var/lib/
	
	service spamassassin start
	service mimedefang start
	service clamav-milter start
	service cyrus-imapd start
	service sendmail start

#fi

elif [ -b /dev/nvme0n1p1 ]; then
	

	mkdir -p /opt/nvme && mount /dev/nvme0n1p1 /opt/nvme

	service sendmail stop
	service cyrus-imapd stop
	service clamav-milter stop
	service mimedefang stop
	service spamassassin stop
	
	mkdir -p /opt/nvme/var/
	mkdir -p /opt/nvme/var/spool/
	mkdir -p /opt/nvme/var/lib/
	
	mkdir -p /opt/nvme/home/
	rm -rf /home.orig && killall gexp && sleep 3
	mv /home/ /home.orig/
	
	if [ ! -d /opt/nvme/home/op/ ]; then
		cp -a /home.orig/op/ /opt/nvme/home/
	fi

	if [ ! -d /opt/nvme/home/postgres/ ]; then
		cp -a /home.orig/postgres/ /opt/nvme/home/
	fi
	
	rm -rf /home.orig
	ln -s /opt/nvme/home/ /		

	if [ -d /opt/nvme/var/log/ ]; then
		rm -rf /var/log.orig
		#mv /var/log/ /var/log.orig
		rm -rf /var/log/
	else
		rm -f /opt/nvme/var/log
		mv /var/log/ /opt/nvme/var/
	fi
	
	ln -s /opt/nvme/var/log /var/

	if [ -d /opt/nvme/var/www/html/cp/public_html/tmp/db_images/ ]; then
		rm -rf /var/www/html/cp/public_html/tmp/db_images.orig
		#mv /var/www/html/cp/public_html/tmp/db_images/ /var/www/html/cp/public_html/tmp/db_images.orig
		rm -rf /var/www/html/cp/public_html/tmp/db_images/
	else
		mkdir -p /opt/nvme/var/www/html/cp/public_html/tmp/
		rm -rf /opt/nvme/var/www/html/cp/public_html/tmp/db_images
	        mv /var/www/html/cp/public_html/tmp/db_images/ /opt/nvme/var/www/html/cp/public_html/tmp/
	fi
	mkdir -p /opt/nvme/var/www/html/cp/public_html/tmp/db_images/ && chown apache /opt/nvme/var/www/html/cp/public_html/tmp/db_images/
	ln -s /opt/nvme/var/www/html/cp/public_html/tmp/db_images/ /var/www/html/cp/public_html/tmp/

	if [ -d /opt/nvme/var/www/html/lightsquid/report/ ]; then
		rm -rf /var/www/html/lightsquid/report.orig
		#mv /var/www/html/lightsquid/report/ /var/www/html/lightsquid/report.orig
		rm -rf /var/www/html/lightsquid/report/
	else
		mkdir -p /opt/nvme/var/www/html/lightsquid/
		rm -rf /opt/nvme/var/www/html/lightsquid/report
	        mv /var/www/html/lightsquid/report/ /opt/nvme/var/www/html/lightsquid/
	fi
	ln -s /opt/nvme/var/www/html/lightsquid/report/ /var/www/html/lightsquid/

	if [ -d /opt/nvme/videos/ ]; then
		mv /var/www/html/cp/public_html/videos/* /opt/nvme/videos/ 
		rm -rf /var/www/html/cp/public_html/videos/
	else
		mkdir -p /opt/nvme/
		rm -rf /opt/nvme/videos
	        mv /var/www/html/cp/public_html/videos/ /opt/nvme/
	fi
	ln -s /opt/nvme/videos/ /var/www/html/cp/public_html/
	
	if [ -d /opt/nvme/var/www/html/mysite/ ]; then
		rm -rf /home/op/mysite.orig
		mv /home/op/mysite/ /home/op/mysite.orig
	else
		mkdir -p /opt/nvme/var/www/html/
		rm -rf /opt/nvme/var/www/html/mysite
	        mv /home/op/mysite/ /opt/nvme/var/www/html/
	fi
	ln -s /opt/nvme/var/www/html/mysite/ /home/op/


	if [ -d /opt/nvme/var/spool/mail/ ]; then
		rm -rf /var/spool/mail.orig
		#mv /var/spool/mail/ /var/spool/mail.orig
		rm -rf /var/spool/mail/		
	else
		rm -rf /opt/nvme/var/spool/mail 
		mv /var/spool/mail/ /opt/nvme/var/spool/
	fi
	ln -s /opt/nvme/var/spool/mail/ /var/spool/

	
	if [ -d /opt/nvme/var/spool/imap/ ]; then
		rm -rf /var/spool/imap.orig
		#mv /var/spool/imap/ /var/spool/imap.orig
		rm -rf /var/spool/imap/
	else
		rm -rf /opt/nvme/var/spool/imap
		mv /var/spool/imap/ /opt/nvme/var/spool/
	fi
	ln -s /opt/nvme/var/spool/imap/ /var/spool/


	if [ -d /opt/nvme/var/lib/imap ]; then
		
		rm -rf /var/lib/imap.orig
		#mv /var/lib/imap/ /var/lib/imap.orig
		rm -rf /var/lib/imap/
	else
		rm -rf /opt/nvme/var/lib/imap
		mv /var/lib/imap/ /opt/nvme/var/lib/
	fi
	ln -s /opt/nvme/var/lib/imap/ /var/lib/

	
	if [ -d /opt/nvme/var/lib/clamav ]; then
		rm -rf /var/lib/clamav.orig
		#mv /var/lib/clamav/ /var/lib/clamav.orig
		rm -rf /var/lib/clamav/
	else
		rm -rf /opt/nvme/var/lib/clamav
		mv /var/lib/clamav/ /opt/nvme/var/lib/
	fi
	ln -s /opt/nvme/var/lib/clamav/ /var/lib/

	service spamassassin start
	service mimedefang start
	service clamav-milter start
	service cyrus-imapd start
	service sendmail start

	
elif [[ ((-b /dev/sda || -b /dev/sdb) && ! (-b /dev/sda1) && ! (-b /dev/sdb1)) ]]; then


	#do not erase VB disk0!
	if [[ -b /dev/sda && ! -b /dev/sda1 && ! $H == "Hypervisor" ]]; then
		echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/sda
		/sbin/mkfs.ext4 /dev/sda1 && mkdir -p /mnt/sda && mount /dev/sda1 /mnt/sda
	fi
		
	if [[ (-b /dev/sdb && ! (-b /dev/sda1) && ! (-b /dev/sdb1)) ]]; then
		echo -e "o\nn\np\n1\n\n\nw" | fdisk /dev/sdb
		/sbin/mkfs.ext4 /dev/sdb1 && mkdir -p /mnt/sda && mount /dev/sdb1 /mnt/sda
	fi
	
	service sendmail stop
	service cyrus-imapd stop
	service clamav-milter stop
	service mimedefang stop
	service spamassassin stop

	mv /home/ /mnt/sda/
	ln -s /mnt/sda/home /home

	mv /var/www/html/cp/public_html/videos/ /mnt/sda/
	ln -s /mnt/sda/videos/ /var/www/html/cp/public_html/
	
	mkdir -p /mnt/sda/var/

	mv /var/log/ /mnt/sda/var/
	ln -s /mnt/sda/var/log /var/log

        mkdir -p /mnt/sda/var/www/html/cp/public_html/tmp/
        mv /var/www/html/cp/public_html/tmp/db_images /mnt/sda/var/www/html/cp/public_html/tmp/
        ln -s /mnt/sda/var/www/html/cp/public_html/tmp/db_images/ /var/www/html/cp/public_html/tmp/db_images

	mkdir -p /mnt/sda/var/www/html/lightsquid/
	mv /var/www/html/lightsquid/report/ /mnt/sda/var/www/html/lightsquid/
	ln -s /mnt/sda/var/www/html/lightsquid/report/ /var/www/html/lightsquid/

	mkdir -p /mnt/sda/var/www/html/
	mv /home/op/mysite/ /mnt/sda/var/www/html/
	ln -s /mnt/sda/var/www/html/mysite/ /home/op/
		
	mkdir -p /mnt/sda/var/spool/

	mv /var/spool/mail/ /mnt/sda/var/spool/
	ln -s /mnt/sda/var/spool/mail /var/spool/mail

	mv /var/spool/imap/ /mnt/sda/var/spool/
	ln -s /mnt/sda/var/spool/imap /var/spool/imap

	mkdir -p /mnt/sda/var/lib/

	mv /var/lib/imap/ /mnt/sda/var/lib/
	ln -s /mnt/sda/var/lib/imap /var/lib/imap

	mv /var/lib/clamav/ /mnt/sda/var/lib/
	ln -s /mnt/sda/var/lib/clamav /var/lib/clamav

	service spamassassin start
	service mimedefang start
	service clamav-milter start
	service cyrus-imapd start
	service sendmail start

#fi

elif [[ (-b /dev/sda1 || (-b /dev/sda2) || (-b /dev/sdb1)) ]]; then
	
   if [ -b /dev/sda1 ]; then
   	SIZE=`/sbin/sfdisk -s /dev/sda`
   	SIZE1=`/usr/sbin/blockdev --getsize64 /dev/sda1`
   	HSIZE1=$(($SIZE1*2))
   elif [ -b /dev/sda2 ]; then   
   	SIZE=`/sbin/sfdisk -s /dev/sda`
	SIZE2=`/usr/sbin/blockdev --getsize64 /dev/sda2`
   	HSIZE2=$(($SIZE2*2))

   elif [ -b /dev/sdb1 ]; then
   	SIZE=`/sbin/sfdisk -s /dev/sdb`
   fi
   
   HSIZE=$(($SIZE*2))

   if [ $(($HSIZE-134217728)) -gt 0 ] || [ $H == "Hypervisor" ]; then

   	if [[ -b /dev/sda1 && $(($HSIZE1-8000000000)) -gt 0 ]]; then
		mkdir -p /mnt/sda && mount /dev/sda1 /mnt/sda
   	elif [[ -b /dev/sda2 && $(($HSIZE2-8000000000)) -gt 0 ]]; then
		mkdir -p /mnt/sda && mount /dev/sda2 /mnt/sda
   	elif [ -b /dev/sdb1 ]; then
		mkdir -p /mnt/sda && mount /dev/sdb1 /mnt/sda

   	fi
	
	mkdir -p /mnt/sda
	mkdir -p /mnt/sda/var/
	mkdir -p /mnt/sda/var/spool/
	mkdir -p /mnt/sda/var/lib/

	service sendmail stop
	service cyrus-imapd stop
	service clamav-milter stop
	service mimedefang stop
	service spamassassin stop
	
	mkdir -p /mnt/sda/home/
	rm -rf /home.orig && killall gexp && sleep 3
	mv /home/ /home.orig/
	
	if [ ! -d /mnt/sda/home/op/ ]; then
		cp -a /home.orig/op/ /mnt/sda/home/
	fi

	if [ ! -d /mnt/sda/home/postgres/ ]; then
		cp -a /home.orig/postgres/ /mnt/sda/home/
	fi
		
	rm -rf /home.orig
	ln -s /mnt/sda/home/ /		

	if [ -d /mnt/sda/var/log/ ]; then
		rm -rf /var/log.orig
		#mv /var/log/ /var/log.orig
		rm -rf /var/log/
	else
		rm -f /mnt/sda/var/log
		mv /var/log/ /mnt/sda/var/
	fi
	ln -s /mnt/sda/var/log /var/

	if [ -d /mnt/sda/var/www/html/cp/public_html/tmp/db_images/ ]; then
		rm -rf /var/www/html/cp/public_html/tmp/db_images.orig
		#mv /var/www/html/cp/public_html/tmp/db_images/ /var/www/html/cp/public_html/tmp/db_images.orig
		rm -rf /var/www/html/cp/public_html/tmp/db_images/
	else
		mkdir -p /mnt/sda/var/www/html/cp/public_html/tmp/
		rm -rf /mnt/sda/var/www/html/cp/public_html/tmp/db_images
	        mv /var/www/html/cp/public_html/tmp/db_images/ /mnt/sda/var/www/html/cp/public_html/tmp/
	fi
	mkdir -p /mnt/sda/var/www/html/cp/public_html/tmp/db_images/ && chown apache /mnt/sda/var/www/html/cp/public_html/tmp/db_images/
	ln -s /mnt/sda/var/www/html/cp/public_html/tmp/db_images/ /var/www/html/cp/public_html/tmp/

	if [ -d /mnt/sda/var/www/html/lightsquid/report/ ]; then
		rm -rf /var/www/html/lightsquid/report.orig
		#mv /var/www/html/lightsquid/report/ /var/www/html/lightsquid/report.orig
		rm -rf /var/www/html/lightsquid/report/
	else
		mkdir -p /mnt/sda/var/www/html/lightsquid/
		rm -rf /mnt/sda/var/www/html/lightsquid/report
	        mv /var/www/html/lightsquid/report/ /mnt/sda/var/www/html/lightsquid/
	fi
	ln -s /mnt/sda/var/www/html/lightsquid/report/ /var/www/html/lightsquid/

	if [ -d /mnt/sda/videos/ ]; then
		mv /var/www/html/cp/public_html/videos/* /mnt/sda/videos/ 
		rm -rf /var/www/html/cp/public_html/videos/
	else
		mkdir -p /mnt/sda/
		rm -rf /mnt/sda/videos
	        mv /var/www/html/cp/public_html/videos/ /mnt/sda/
	fi
	ln -s /mnt/sda/videos/ /var/www/html/cp/public_html/
	
	if [ -d /mnt/sda/var/www/html/mysite/ ]; then
		rm -rf /home/op/mysite.orig
		mv /home/op/mysite/ /home/op/mysite.orig
	else
		mkdir -p /mnt/sda/var/www/html/
		rm -rf /mnt/sda/var/www/html/mysite
	        mv /home/op/mysite/ /mnt/sda/var/www/html/
	fi
	ln -s /mnt/sda/var/www/html/mysite/ /home/op/
	
	if [ -d /mnt/sda/var/spool/mail/ ]; then
		rm -rf /var/spool/mail.orig
		#mv /var/spool/mail/ /var/spool/mail.orig
		rm -rf /var/spool/mail/
	else
		rm -rf /mnt/sda/var/spool/mail 
		mv /var/spool/mail/ /mnt/sda/var/spool/
	fi
	ln -s /mnt/sda/var/spool/mail/ /var/spool/

	
	if [ -d /mnt/sda/var/spool/imap/ ]; then
		rm -rf /var/spool/imap.orig
		#mv /var/spool/imap/ /var/spool/imap.orig
		rm -rf /var/spool/imap/
	else
		rm -rf /mnt/sda/var/spool/imap
		mv /var/spool/imap/ /mnt/sda/var/spool/
	fi
	ln -s /mnt/sda/var/spool/imap/ /var/spool/


	if [ -d /mnt/sda/var/lib/imap ]; then
		
		rm -rf /var/lib/imap.orig
		#mv /var/lib/imap/ /var/lib/imap.orig
		rm -rf /var/lib/imap/
	else
		rm -rf /mnt/sda/var/lib/imap
		mv /var/lib/imap/ /mnt/sda/var/lib/
	fi
	ln -s /mnt/sda/var/lib/imap/ /var/lib/

	
	if [ -d /mnt/sda/var/lib/clamav ]; then
		rm -rf /var/lib/clamav.orig
		#mv /var/lib/clamav/ /var/lib/clamav.orig
		rm -rf /var/lib/clamav/
	else
		rm -rf /mnt/sda/var/lib/clamav
		mv /var/lib/clamav/ /mnt/sda/var/lib/
	fi
	ln -s /mnt/sda/var/lib/clamav/ /var/lib/

	service spamassassin start
	service mimedefang start
	service clamav-milter start
	service cyrus-imapd start
	service sendmail start

   #and a small flash, we may want to use it for proxy logs
   else
	
	SDA_MOUNTABLE=1
	if [ -b /dev/sda1 ]; then
		if [ ! -n "`mount | grep /dev/sda1`" ]; then
		  mkdir -p /mnt/sda && mount /dev/sda1 /mnt/sda 
		fi
		sleep 2
		if [ -n "`mount | grep /dev/sda1`" ]; then
		  if [ -d /mnt/sda/var/www/html/lightsquid/report/ ]; then
			rm -rf /var/www/html/lightsquid/report.orig
			#mv /var/www/html/lightsquid/report/ /var/www/html/lightsquid/report.orig
			rm -rf /var/www/html/lightsquid/report/
		  else
			mkdir -p /mnt/sda/var/www/html/lightsquid/
			rm -rf /mnt/sda/var/www/html/lightsquid/report
	        	mv /var/www/html/lightsquid/report/ /mnt/sda/var/www/html/lightsquid/
		  fi
		  rm -f /var/www/html/lightsquid/report
		  ln -s /mnt/sda/var/www/html/lightsquid/report/ /var/www/html/lightsquid/
		else
			SDA_MOUNTABLE=0
		fi
		
	fi
	
	if [ $SDA_MOUNTABLE -eq 0 ] && [ -b /dev/sdb1 ]; then
		if [ ! -n "`mount | grep /dev/sdb1`" ]; then
		  mkdir -p /mnt/sda && mount /dev/sdb1 /mnt/sda
		fi		
		sleep 2
		if [ -n "`mount | grep /dev/sdb1`" ]; then	
		  if [ -d /mnt/sda/var/www/html/lightsquid/report/ ]; then
			rm -rf /var/www/html/lightsquid/report.orig
			#mv /var/www/html/lightsquid/report/ /var/www/html/lightsquid/report.orig
			rm -rf /var/www/html/lightsquid/report/
		  else
			mkdir -p /mnt/sda/var/www/html/lightsquid/
			rm -rf /mnt/sda/var/www/html/lightsquid/report
	        	mv /var/www/html/lightsquid/report/ /mnt/sda/var/www/html/lightsquid/
		  fi
		  rm -f /var/www/html/lightsquid/report
		  ln -s /mnt/sda/var/www/html/lightsquid/report/ /var/www/html/lightsquid/
		fi
	fi
   fi # drive < 64G
else
#everything goes into RAM
   echo shit
fi
