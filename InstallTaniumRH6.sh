#!/bin/env bash
# Script to install the Tanium Linux rpm package, place the .pub file and set agency tag
# FOR RHEL 6 FAMILY - 32 or 64 BIT
# Kevin Burg - kevin.burg@state.co.us

PUBLICSERVERIP=165.127.219.171
OITSERVERIP=10.51.2.112
VERBOSITY=0
SERVERPORT=17472
TANIUMRH6RPMSUM64="9b2498ef037938c5de4d474271292597a6fe406353c6cd67bf13fd56572e2595"
TANIUMRH6RPMSUM32="d898a9d5beee3226830639637999a857fb216615d6279bee9e2dc6f923f4e856"
TANIUMPUBSUM="62a9f750e234c897e1a543d13afab3346a6e3544312bf762ab0c278a45545b9d"
F_RED="\e[38;2;255;0;0m"
F_GREEN="\e[38;2;0;255;0m"
RESET="\e[0m"
ARCHITECTURE="$(uname -m)"

if (( ${EUID} != 0 )); then
 echo -e "${F_RED}You need to be root or use sudo to run this script"
 echo -e "For example: sudo ./InstallTaniumRH6.sh${RESET}"
 exit 1
fi

if [ -e /etc/redhat-release ]
 then
 LINUX=$(cat /etc/redhat-release | awk -F' ' '{ print $1}')
 if [[ ${LINUX} != "Red" ]]
 then
  echo -e "${F_RED}This does not appear to be a RHEL 6 system, exiting${RESET}"
  exit 1
 else
  RHELVER=$(cat /etc/redhat-release | awk -F' ' '{ print $7 }')
  case ${RHELVER} in
   6.0 | 6.1 | 6.2 | 6.3 | 6.4 | 6.5 | 6.6 | 6.7 | 6.8 | 6.9 | 6.10)
   ;;
   *)
   echo -e "${F_RED}This script does not support RHEL version ${RHELVER}, exiting"
   exit 1
   ;;
  esac
 fi
 else
  echo -e "${F_RED}This does not appear to be a RHEL system, exiting${RESET}"
  exit 1
fi

if [[ ${ARCHITECTURE} = "x86_64" ]]
then
 ls ./[Tt]an*x86_64.rpm > /dev/null 2>&1
 if (( $? == 0 ))
  then
  INSTALLPKG=$(ls [Tt]an*x86_64.rpm)
  if [[ ${TANIUMRH6RPMSUM64} != $(sha256sum ${INSTALLPKG} | awk -F' ' '{ print $1 }') ]]
   then
    echo -e "${F_RED}Tanium RPM sha256sum does not match, file may be corrupt"
    echo -e "Please download a fresh copy and try again. Script will now exit.${RESET}"
    exit 1
  fi
 else
  echo -e "${F_RED}Tanium RPM file not found in this directory, exiting${RESET}"
  exit 1
 fi
else
 ls ./[Tt]an*i686.rpm > /dev/null 2>&1
 if (( $? == 0 ))
  then
  INSTALLPKG=$(ls [Tt]an*i686.rpm)
  if [[ ${TANIUMRH6RPMSUM32} != $(sha256sum ${INSTALLPKG} | awk -F' ' '{ print $1 }') ]]
   then
    echo -e "${F_RED}Tanium RPM sha256sum does not match, file may be corrupt"
    echo -e "Please download a fresh copy and try again. Script will now exit.${RESET}"
    exit 1
  fi
  else
   echo -e "${F_RED}Tanium RPM file not found in this directory, exiting${RESET}"
   exit 1
  fi
fi

ls ./[Tt]an*.pub > /dev/null 2>&1
if (( $? == 0 ))
 then
 INSTALLPUB=$(ls [Tt]an*.pub)
 if [[ ${TANIUMPUBSUM} != $(sha256sum ${INSTALLPUB} | awk -F' ' '{ print $1 }') ]]
  then
   echo -e "${F_RED}Tanium pub sha256sum does not match, file may be corrupt"
   echo -e "Please download a fresh copy and try again. Script will now exit${RESET}"
   exit 1
 fi
else
 echo -e "${F_RED}Tanium .pub file not found in this directory, exiting${RESET}"
 exit 1
fi

echo -e "${F_GREEN}      _________    _   ________  ____  ___"
echo -e "     /_  __/   |  / | / /  _/ / / /  |/  /"
echo -e "      / / / /| | /  |/ // // / / / /|_/ /"
echo -e "     / / / ___ |/ /|  // // /_/ / /  / /"
echo -e "    /_/ /_/  |_/_/ |_/___/\____/_/  /_/${RESET}"

echo -e "\n"
echo -e "This script is for Redhat Enterprise Linux version 6"
echo -e "This script supports the following Agencies:"
echo -e "  1 - CDA \t\t 11 - DOC"
echo -e "  2 - CDHS \t\t 12 - DOLA"
echo -e "  3 - CDLE \t\t 13 - DOR"
echo -e "  4 - CDOT \t\t 14 - DORA"
echo -e "  5 - CDPHE \t\t 15 - DPA"
echo -e "  6 - CDPS \t\t 16 - GOV"
echo -e "  7 - CHS \t\t 17 - HCPF"
echo -e "  8 - CST \t\t 18 - OIT"
echo -e "  9 - DMVA \t\t 19 - OITEDIT"
echo -e " 10 - DNR\n"
echo -n "Please enter agency number and press [ENTER]: "
read RESPONSE
case ${RESPONSE} in
 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 19)
   SERVERIP=${PUBLICSERVERIP}
   ;;
 18)
   SERVERIP=${OITSERVERIP}
   ;;
 *)
   echo -e "${F_RED}That is not a valid agency number, exiting.${RESET}"
   exit 1
   ;;
esac

if [ ${RESPONSE} -eq 1 ]
 then AGENCY="CDA"
elif [ ${RESPONSE} -eq 2 ]
 then AGENCY="CDHS"
elif [ ${RESPONSE} -eq 3 ]
 then AGENCY="CDLE"
elif [ ${RESPONSE} -eq 4 ]
 then AGENCY="CDOT"
elif [ ${RESPONSE} -eq 5 ]
 then AGENCY="CDPHE"
elif [ ${RESPONSE} -eq 6 ]
 then AGENCY="CDPS"
elif [ ${RESPONSE} -eq 7 ]
 then AGENCY="CHS"
elif [ ${RESPONSE} -eq 8 ]
 then AGENCY="CST"
elif [ ${RESPONSE} -eq 9 ]
 then AGENCY="DMVA"
elif [ ${RESPONSE} -eq 10 ]
 then AGENCY="DNR"
elif [ ${RESPONSE} -eq 11 ]
 then AGENCY="DOC"
elif [ ${RESPONSE} -eq 12 ]
 then AGENCY="DOLA"
elif [ ${RESPONSE} -eq 13 ]
 then AGENCY="DOR"
elif [ ${RESPONSE} -eq 14 ]
 then AGENCY="DORA"
elif [ ${RESPONSE} -eq 15 ]
 then AGENCY="DPA"
elif [ ${RESPONSE} -eq 16 ]
 then AGENCY="GOV"
elif [ ${RESPONSE} -eq 17 ]
 then AGENCY="HCPF"
elif [ ${RESPONSE} -eq 18 ]
 then AGENCY="OIT"
elif [ ${RESPONSE} -eq 19 ]
 then AGENCY="OITEDIT"
fi

echo -e "Installing Tanium Package: ${F_GREEN}${INSTALLPKG}${RESET}"
rpm -ivh ./${INSTALLPKG}
sleep 5
echo -e "Installing pub file: ${F_GREEN}${INSTALLPUB}${RESET}"
cp ./${INSTALLPUB} /opt/Tanium/TaniumClient/
echo -e "Setting parameters:"
echo -e "  Tanium server IP: ${F_GREEN}${SERVERIP}${RESET}"
echo -e "  Tanium server port: ${F_GREEN}${SERVERPORT}${RESET}"
echo -e "  Tanium log verbosity level: ${F_GREEN}${VERBOSITY}${RESET}"
/opt/Tanium/TaniumClient/TaniumClient config set ServerNameList ${SERVERIP}
/opt/Tanium/TaniumClient/TaniumClient config set ServerPort ${SERVERPORT}
/opt/Tanium/TaniumClient/TaniumClient config set LogVerbosityLevel ${VERBOSITY}
echo -e "Setting custom tag to: ${F_GREEN}${AGENCY}${RESET}"
echo -e "${AGENCY}" > /opt/Tanium/TaniumClient/Tools/CustomTags.txt
echo -e "Starting TaniumClient service"
service TaniumClient start
echo -e "${F_GREEN}Install Complete${RESET}"
echo -e "${F_RED}Please verify that firewall port ${SERVERPORT}/TCP is open to ${SERVERIP}${RESET}"
exit 0
