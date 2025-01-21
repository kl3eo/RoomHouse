#!/bin/sh
#set -x
DIR=/var/log/ipcad

# Move IP accounting to checkpoint
#rsh localhost clear ip accounting >> /dev/null
# Show saved IP accounting
#rsh localhost show ip accounting checkpoint > $DIR/last
# Clear checkpoint
#rsh localhost clear ip accounting checkpoint >> /dev/null

/bin/cp -a /usr/local/var/ipcad/ipcad.dump $DIR/last
set `date +"%Y %m %d %H %M"`
OUT=$DIR/stat/$1/$2
DAYZIP=$3.zip
DAYZIPNAME=$3
FILENAME="$4-$5"
if [ ! -d $OUT ]
then
  mkdir -p $OUT
fi

grep 212.44.138. < $DIR/last > $OUT/$FILENAME.eth0
egrep -v 212.44.138. < $DIR/last > $OUT/$FILENAME.othr

/usr//bin/zip -qjm $OUT/$DAYZIPNAME-eth0.zip $OUT/$FILENAME.eth0
/usr/bin/zip -qjm $OUT/$DAYZIPNAME-othr.zip $OUT/$FILENAME.othr

exit

