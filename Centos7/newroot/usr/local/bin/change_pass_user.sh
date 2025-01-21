#!/bin/bash

if [ -f /etc/sysconfig/interfaces ]; then
    . /etc/sysconfig/interfaces
else
        echo "Interfaces description not found, exiting.."
        exit 1
fi

if [ "$#" -ne 2 ]; then
    echo "USAGE: ./change_pass_user.sh USER NEWPASS" && exit
fi

USER=$1
PASS=$2

smbpasswd -x $USER
saslpasswd2 -f /etc/sasldb2 -d $USER
userdel -r $USER

useradd -p $(openssl passwd -1 $PASS) $USER
(echo $PASS; echo $PASS;) | smbpasswd -a -s $USER
echo $PASS | saslpasswd2 -p -f /etc/sasldb2 -c $USER

echo "poll mail.uniqa.ru proto pop3 username $USER%uniqa.ru password $PASS smtphost localhost smtpname $USER nokeep ssl" > /home/$USER/.fetchmailrc
chown $USER:users /home/$USER/.fetchmailrc
chmod 710 /home/$USER/.fetchmailrc

cyradm -U cyrus -w $CLIENTNAME localhost << SCRIPT
sam user.$USER $USER all
SCRIPT

if [ -f /etc/sysconfig/primary_host ]; then
killall fetchmail
/etc/rc.d/fetchmail.lc
fi
