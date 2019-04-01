#!/usr/bin/env bash
# Purpose: Check hostnames from a file or individually and see if DNS has stale records
#          Loop from the cmd line instead of INFILE
# Date: 20181031
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
# INFILE=/home/burgk/scripts/IP_Relay_Addrs.txt
f_red="\e[38;2;255;0;0m"
f_green="\e[38;2;0;255;0m"
f_yellow="\e[38;2;255;255;0m"
f_gold="\e[38;2;255;215;0m"
f_white="\e[38;2;255;255;255m"
reset="\e[0m"
fdnshost=${1^^} # Use parameter expansion to make result all CAPS
logfile="/home/burgk/dnscheck.txt"
# }}}

# Begin main tasks {{{
if host "${fdnshost}" &> /dev/null; then
  fdnshostaddr=$(host "${fdnshost}" | awk -F' ' '{ print $4 }')
else
  echo -e "${f_red}${fdnshost} is not in DNS${reset}"
  echo -e "${fdnshost} is not in DNS" 1>>${logfile}
  exit 1
fi

echo -e "Forward record shows ${f_yellow}${fdnshost}${reset} is ${f_yellow}${fdnshostaddr}${reset}"
echo -e "Forward record shows ${fdnshost} is ${fdnshostaddr}" 1>>${logfile}
host "${fdnshostaddr}" &> /dev/null
if [ $? == 1 ]; then
  echo -e "${f_red}No reverse record${reset}"
  echo -e "No reverse record" 1>>${logfile} 
else
  rdnshost=$(host "${fdnshostaddr}" | awk -F' ' '{ print $5 }' | cut -d. -f1 | tr '[:lower:]' '[:upper:]') 
  echo -e "Reverse record shows ${f_gold}${rdnshost}${reset} is ${f_gold}${fdnshostaddr}${reset}"
  echo -e "Reverse record shows ${rdnshost} is ${fdnshostaddr}" 1>>${logfile}
  if [ "${fdnshost}" == "${rdnshost}" ]; then
    echo -e "${f_green}Forward and Reverse match${reset}"
    echo -e "Forward and Reverse match" 1>>${logfile}
  else
    echo -e "${f_red}Forward and Reverse are different${reset}"
    echo -e "Forward and Reverse are different" 1>>${logfile}
  fi
fi

if ping -c 1 "${fdnshostaddr}" &> /dev/null; then
  echo -e "${f_green}${fdnshostaddr} responds to ping${reset} \n"
  echo -e "${fdnshostaddr} responds to ping \n" 1>>${logfile}
else
  echo -e "${f_red}${fdnshostaddr} not pingable${reset} \n"
  echo -e "${fdnshostaddr} not pingable \n" 1>>${logfile}
fi # }}}

exit 0
