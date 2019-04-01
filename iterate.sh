#!/usr/bin/env bash
# Iterate over the lines in a file and perform a command on each line

# INFILE=/home/burgk/scripts/public_shares.txt
# INFILE=/home/burgk/scripts/50_poweredoff.txt
INFILE=/home/burgk/20180221_cdotvm-sub.txt
# INFILE=/home/burgk/scripts/IP_Relay_Addrs.txt

# Setting IFS doesn't seem to be needed, but I put it in just in case
# IFS='\'

# while read -r SHARE; do
# 	echo -e "\n"
#	echo -e Permission for share: "${SHARE}"
#	echo -e ---------------------
#	echo -e	isi smb shares permission modify "${SHARE}" --wellknown Everyone --permission-type allow --permission full --zone=CDOT
#	isi smb shares permission list "$SHARE" --zone CDOT2
# done < ${INFILE}

while read -r VMNAME; do
  echo -e "Checking ${VMNAME}"
    host ${VMNAME} &> /dev/null
    if [ $? == 0 ]
    then
      TMPNAME=$(host ${VMNAME} | awk -F' ' '{ print $5 }')
      echo -e "${VMNAME} is in DNS as ${TMPNAME}, lets ping it.."
      # echo -e "Trying to ping ${VMNAME}"
      ping -c 1 ${VMNAME} &> /dev/null
      if [ $? == 1 ]
      then
        echo -e "${VMNAME} is NOT reachable :-("
        echo -e "\n"
      else
	      echo -e "Yep, ${VMNAME} / ${TMPNAME}  is alive :-)"
          echo -e "lets check for encrypted files.."
        mount -t cifs -o username=burgkadm,password="p3rtHCo|a",domain=dot.state.co.us //${VMNAME}/c$ /mnt2
        find /mnt2 -maxdept 2 -iname "*.weapologize" &> /dev/null
        sleep 10
        if [ $? == 0 ]
        then
         echo -e "${VMNAME} has encrypted files"
         echo -e "${VMNAME}" >> /home/burgk/20180221_infectedhosts.txt
         umount /mnt2
         else
          echo -e "${VMNAME} not infected"
          fi
        umount /mnt2
        echo -e "\n"
      fi
    else
      echo -e "${VMNAME} is NOT in DNS, but will it ping..."
      ping -c 1 ${VMNAME} &> /dev/null
        if [ $? == 1 ]
	then
          echo -e "${VMNAME} is NOT reachable :-("
	  echo -e "\n"
	else
		echo -e "Yep, ${VMNAME} is alive :-)"
	  echo -e "\n"
	fi
#      echo -e "\n"
    fi
done < ${INFILE}
