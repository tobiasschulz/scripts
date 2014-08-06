#!/bin/bash

export n=100

if [[ "x$1" == "x" ]]
then
	tail -n $n /var/log/syslog
else
	if [[ "x$1" == "x-f" ]]
	then
		if [[ "x$2" == "x" ]]
		then
			tail -f -n $n /var/log/syslog
		else
			tail -f -n $2 /var/log/syslog
		fi
	else
		tail $2 -n $1 /var/log/syslog
	fi
fi
