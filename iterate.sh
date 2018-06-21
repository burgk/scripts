#!/usr/bin/env bash
# Kevin Burg - burg.kevin@gmail.com
# Iterate over the lines in a file and perform a command on each line

INFILE=/home/burgk/scripts/masterserverinventorymissingls.txt

# Setting IFS doesn't seem to be needed, but I put it in just in case
# IFS='\'

while read -r IP; do
	echo -e "\n"
	echo -e Lookup on: "${IP}"
	echo -e ---------------------
#	echo -e	isi smb shares permission modify "${SHARE}" --wellknown Everyone --permission-type allow --permission full --zone=CDOT
	nslookup ${IP}
#	sleep 2
#	isi smb shares permission list "$SHARE" --zone CDOT2
done < ${INFILE}
