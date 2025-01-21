#!/bin/bash
if (( "$1" == 1 )) ; then
	/bin/touch /tmp/pirl_flag
elif (( "$1" == 2 )) ; then
	/bin/unlink /tmp/pirl_flag
elif (( "$1" == 3 )) ; then
	/bin/touch /tmp/gexp_flag
elif (( "$1" == 4 )) ; then
	/bin/unlink /tmp/gexp_flag
elif (( "$1" == 5 )) ; then
	/bin/touch /tmp/geth_flag
elif (( "$1" == 6 )) ; then
	/bin/unlink /tmp/geth_flag
fi

