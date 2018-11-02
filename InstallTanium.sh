#!/bin/env bash
# Script to install the Tanium Linux rpm package, place the .pub file and set agency tag
# Kevin Burg - kevin.burg@state.co.us

PUBLICSERVERIP=165.127.219.171
OITSERVERIP=10.51.2.112
VERBOSITY=0
F_RED="\e[38;2;255;0;0m"
F_GREEN="\e[38;2;0;255;0m"
RESET="\e[0m"

ls ./*.rpm > /dev/null 2>&1
if (( $? == 0 ))
 then
 INSTALLPKG=$(ls *.rpm)
else
 echo -e "${F_RED}Tanium RPM file not found in this directory, exiting${RESET}"
 exit 1
fi
ls ./*.pub > /dev/null 2>&1
if (( $? == 0 ))
 then
 INSTALLPUB=$(ls *.pub)
else
 echo -e "${F_RED}Tanium .pub file not found in this directory, exiting${RESET}"
 exit 1
fi

if (( ${EUID} != 0 )); then
 echo "${F_RED}You need to be root or use sudo to run this script"
 echo "For example: sudo ./InstallTanium.sh${RESET}"
 exit 1
fi

echo -e "${F_GREEN}      _________    _   ________  ____  ___"
echo -e "     /_  __/   |  / | / /  _/ / / /  |/  /"
echo -e "      / / / /| | /  |/ // // / / / /|_/ /"
echo -e "     / / / ___ |/ /|  // // /_/ / /  / /"
echo -e "    /_/ /_/  |_/_/ |_/___/\____/_/  /_/${RESET}"

echo -e "\n"
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
echo -e "Installing pub file: ${F_GREEN}${INSTALLPUB}${RESET}"
cp ./${INSTALLPUB} /opt/tanium/TaniumClient
echo -e "Setting parameters:"
echo -e "  Tanium server is: ${F_GREEN}${SERVERIP}${RESET}"
echo -e "  Tanium log verbosity level: ${F_GREEN}${VERBOSITY}${RESET}"
/opt/tanium/TaniumClient/TaniumClient config set ServerNameList ${SERVERIP}
/opt/tanium/TaniumClient/TaniumClient config set LogVerbosityLevel ${VERBOSITY}
echo -e "Setting custom tag to: ${F_GREEN}${AGENCY}${RESET}"
echo -e "${AGENCY}" > /opt/tanium/TaniumClient/CustomTags.txt
echo -e "${F_GREEN}Install Complete"
echo -e "Please verify that firewall port 17472/TCP is open to ${SERVERIP}${RESET}"
exit 0
