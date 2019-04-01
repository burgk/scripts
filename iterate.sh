#!/usr/bin/env bash
# Iterate over the lines in a file and perform a command on each line

# infile=/home/burgk/scripts/public_shares.txt
# infile=/home/burgk/scripts/50_poweredoff.txt
infile=/home/burgk/20180221_cdotvm-sub.txt
# infile=/home/burgk/scripts/IP_Relay_Addrs.txt

# Setting IFS doesn't seem to be needed, but I put it in just in case
# IFS='\'

# while read -r SHARE; do
# 	echo -e "\n"
#	echo -e Permission for share: "${SHARE}"
#	echo -e ---------------------
#	echo -e	isi smb shares permission modify "${SHARE}" --wellknown Everyone --permission-type allow --permission full --zone=CDOT
#	isi smb shares permission list "$SHARE" --zone CDOT2
# done < ${infile}

while read -r vmname; do
echo -e "Checking ${vmname}"
host ${vmname} &> /dev/null
if [ $? == 0 ]; then
  tmpname=$(host ${vmname} | awk -F' ' '{ print $5 }')
  echo -e "${vmname} is in DNS as ${tmpname}, lets ping it.."
  # echo -e "Trying to ping ${vmname}"
  ping -c 1 "${vmname}" &> /dev/null
  if [ $? == 1 ]; then
    echo -e "${vmname} is NOT reachable :-("
    echo -e "\n"
  else
    echo -e "Yep, ${vmname} / ${tmpname}  is alive :-)"
    echo -e "lets check for encrypted files.."
     mount -t cifs -o username=burgkadm,password="",domain=dot.state.co.us //"${vmname}"/c$ /mnt2
     find /mnt2 -maxdept 2 -iname "*.weapologize" &> /dev/null
     sleep 10
     if [ $? == 0 ]; then
       echo -e "${vmname} has encrypted files"
       echo -e "${vmname}" >> /home/burgk/20180221_infectedhosts.txt
       umount /mnt2
     else
       echo -e "${vmname} not infected"
     fi
       umount /mnt2
       echo -e "\n"
  fi
  else
    echo -e "${vmname} is NOT in DNS, but will it ping..."
    ping -c 1 "${vmname}" &> /dev/null
    if [ $? == 1 ]; then
      echo -e "${vmname} is NOT reachable :-("
	  echo -e "\n"
	else
	  echo -e "Yep, ${vmname} is alive :-)"
	  echo -e "\n"
	fi
fi
done < ${infile}
