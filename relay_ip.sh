#!/usr/bin/env bash

# INFILE=/home/burgk/scripts/subset.txt
INFILE=/home/burgk/scripts/IP_Relay_Addrs.txt

while read -r IPADDR; do
	host ${IPADDR} &> /dev/null
	if [ $? == 0 ]
	then
		TMPNAME=$(host ${IPADDR} | awk -F' ' '{ print $5 }')
		ping -c 1 ${IPADDR} &> /dev/null
		if [ $? == 0 ]
		then
			PINGSTATUS="Online"
		else
			PINGSTATUS="Offline"
		fi
		echo -e "${IPADDR},${TMPNAME},${PINGSTATUS}"
	else
		ping -c 1 ${IPADDR} &> /dev/null
		if [ $? == 0 ]
		then
			PINGSTATUS="Online"
		else
			PINGSTATUS="Offline"
		fi
		echo -e "${IPADDR},"",${PINGSTATUS}"
	fi
done < ${INFILE}
