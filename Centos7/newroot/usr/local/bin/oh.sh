#!/bin/sh

SPEED=5
if (( "$1" == 1 )) ; then
SPEED=20
elif (( "$1" == 2 )) ; then
SPEED=40
elif (( "$1" == 3 )) ; then
SPEED=60
elif (( "$1" == 4 )) ; then
SPEED=80
elif (( "$1" == 5 )) ; then
SPEED=95
fi

/usr/bin/ohgodatool -i 0 --set-fanspeed $SPEED
/usr/bin/ohgodatool -i 1 --set-fanspeed $SPEED
/usr/bin/ohgodatool -i 2 --set-fanspeed $SPEED
/usr/bin/ohgodatool -i 3 --set-fanspeed $SPEED
/usr/bin/ohgodatool -i 4 --set-fanspeed $SPEED
/usr/bin/ohgodatool -i 5 --set-fanspeed $SPEED
/usr/bin/ohgodatool -i 6 --set-fanspeed $SPEED
/usr/bin/ohgodatool -i 7 --set-fanspeed $SPEED
