#!/usr/bin/env bash
# Iterate over the lines in a file and perform a command on each line

# INFILE=/home/burgk/scripts/IP_Relay_Addrs.txt

RED="\e[38;2;255;0;0m"
GREEN="\e[38;2;0;255;0m"
YELLOW="\e[38;2;255;255;0m"
GOLD="\e[38;2;255;215;0m"
WHITE="\e[38;2;255;255;255m"
RESET="\e[0m"
FDNSHOST=${1^^}
LOGFILE="/home/burgk/dnscheck.txt"
host ${FDNSHOST} &> /dev/null
 if [ $? == 0 ]
 then
  FDNSHOSTADDR=$(host ${FDNSHOST} | awk -F' ' '{ print $4 }')
 else
  echo -e "${RED}${FDNSHOST} is not in DNS${RESET}"
  echo -e "${FDNSHOST} is not in DNS" 1>>${LOGFILE}
  exit 1
 fi
echo -e "Forward record shows ${YELLOW}${FDNSHOST}${RESET} is ${YELLOW}${FDNSHOSTADDR}${RESET}"
echo -e "Forward record shows ${FDNSHOST} is ${FDNSHOSTADDR}" 1>>${LOGFILE}
host ${FDNSHOSTADDR} &> /dev/null
 if [ $? == 1 ]
 then
  echo -e "${RED}No reverse record${RESET}"
  echo -e "No reverse record" 1>>${LOGFILE} 
 else
  RDNSHOST=$(host ${FDNSHOSTADDR} | awk -F' ' '{ print $5 }' | cut -d. -f1 | tr '[:lower:]' '[:upper:]') 
  echo -e "Reverse record shows ${GOLD}${RDNSHOST}${RESET} is ${GOLD}${FDNSHOSTADDR}${RESET}"
  echo -e "Reverse record shows ${RDNSHOST} is ${FDNSHOSTADDR}" 1>>${LOGFILE}
  if [ ${FDNSHOST} == ${RDNSHOST} ]
  then
   echo -e "${GREEN}Forward and Reverse match${RESET}"
   echo -e "Forward and Reverse match" 1>>${LOGFILE}
  else
   echo -e "${RED}Forward and Reverse are different${RESET}"
   echo -e "Forward and Reverse are different" 1>>${LOGFILE}
  fi
 fi
ping -c 1 ${FDNSHOSTADDR} &> /dev/null
 if [ $? == 1 ]
 then
  echo -e "${RED}${FDNSHOSTADDR} not pingable${RESET} \n"
  echo -e "${FDNSHOSTADDR} not pingable \n" 1>>${LOGFILE}
 else
  echo -e "${GREEN}${FDNSHOSTADDR} responds to ping${RESET} \n"
  echo -e "${FDNSHOSTADDR} responds to ping \n" 1>>${LOGFILE}
 fi
