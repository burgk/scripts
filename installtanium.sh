#!/bin/bash
# Script to install supported Linux Tanium clients
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definions #{{{
oitserverip=10.51.2.112
publicserverip=165.127.219.171
taniumport=17472
verbosity=0
# Console colors
f_red="\e[38;2;255;0;0m"
f_green="\e[38;2;0;255;0m"
reset="\e[0m"
# Tanium packages and files
taniumpub="./tanium.pub"
debian67_32="./taniumclient_7.2.314.3476-debian6_i386.deb"
debian67_64="./taniumclient_7.2.314.3476-debian6_amd64.deb"
debian8_32="./taniumclient_7.2.314.3476-debian8_i386.deb"
debian8_64="./taniumclient_7.2.314.3476-debian8_amd64.deb"
debian9_32="./taniumclient_7.2.314.3476-debian9_i386.deb"
debian9_64="./taniumclient_7.2.314.3476-debian9_amd64.deb"
oracle5_32="./TaniumClient-7.2.314.3476-1.oel5.i386.rpm"
oracle5_64="./TaniumClient-7.2.314.3476-1.oel5.x86_64.rpm"
oracle6_32="./TaniumClient-7.2.314.3476-1.oel6.i686.rpm"
oracle6_64="./TaniumClient-7.2.314.3476-1.oel6.x86_64.rpm"
oracle7_64="./TaniumClient-7.2.314.3476-1.oel7.x86_64.rpm"
rhel5_32="./TaniumClient-7.2.314.3476-1.rhe5.i386.rpm"
rhel5_64="./TaniumClient-7.2.314.3476-1.rhe5.x86_64.rpm"
rhel6_32="./TaniumClient-7.2.314.3476-1.rhe6.i686.rpm"
rhel6_64="./TaniumClient-7.2.314.3476-1.rhe6.x86_64.rpm"
rhel7_64="./TaniumClient-7.2.314.3476-1.rhe7.x86_64.rpm"
suse11_32="./TaniumClient-7.2.314.3476-1.sle11.i586.rpm"
suse11_64="./TaniumClient-7.2.314.3476-1.sle11.x86_64.rpm"
suse12_32="./TaniumClient-7.2.314.3476-1.sle12.i586.rpm"
suse12_64="./TaniumClient-7.2.314.3476-1.sle12.x86_64.rpm"
ubuntu10_32="./taniumclient_6.0.314.3476-ubuntu10_i386.deb"
ubuntu10_64="./taniumclient_7.2.314.3476-ubuntu10_amd64.deb"
ubuntu14_64="./taniumclient_7.2.314.3476-ubuntu14_amd64.deb"
ubuntu16_64="./taniumclient_7.2.314.3476-ubuntu16_amd64.deb"
ubuntu18_64="./taniumclient_7.2.314.3476-ubuntu18_amd64.deb"
#}}}

check_root() { #{{{
  if (( ${EUID} != 0 )); then
    echo -e "${f_red}You need to be root or use sudo to run this script"
    echo -e "For example: sudo ./$(basename ${0})${reset}"
    exit 1
  fi
} #}}}

get_distro() { #{{{
operatingsystem=$(uname -o)
if [[ ${operatingsystem} != *inux* ]]; then
  echo -e "${f_red}This script is only designed to work with Linux hosts"
  echo -e "It found ${operatingsystem} instead and cannot continue.${reset}"
  exit 1
fi

if [[ -e /etc/os-release ]]; then # Should get most supported systems
  distro=$(grep ^NAME /etc/os-release | awk -F'=' '{print $2}' | awk -F' ' '{print $1}' | tr -d '"')
  case ${distro} in
  CentOS | Oracle | SLES | openSUSE | Debian | debian | Ubuntu)
    supported_distro=true
  ;;
  Red)
    distro="Redhat"
    supported_distro=true
  ;;
  *)
    supported_distro=false
  ;;
  esac
elif [[ -e /etc/lsb-release ]]; then # Gets old Ubuntu
  distro=$(grep DISTRIB_ID /etc/lsb-release | awk -F'=' '{print $2}' | tr -d '"')
  if [[ ${distro} = *buntu* ]]; then
    supported_distro=true
  else
    supported_distro=false
  fi
elif [[ -e /etc/SuSE-release ]]; then # Gets old openSuse
  distro=$(head -n1 /etc/SuSE-release | awk -F' ' '{print $1}')
  if [[ ${distro} = "openSUSE" ]]; then
    supported_distro=true
  else
    supported_distro=false
  fi
else # Gets old Debian
  distro=$(for f in $(find /etc -maxdepth 1 -type f \( ! -path /etc/lsb-release -path /etc/\*release -o -path /etc/\*version \) ); do echo ${f:5:${#f}-13};done)
    if [[ ${distro} = *ebian ]]; then
      supported_distro=true
    else
      supported_distro=false
    fi
fi
} #}}}

get_distroversion() { #{{{
case ${distro} in
  CentOS | Oracle | SLES | openSUSE | Redhat)
    if [[ -e /etc/os-release ]]; then
      majversion=$(grep -w ^VERSION_ID /etc/os-release | awk -F'=' '{print $2}' | awk -F' ' '{print $1}' | tr -d '"' | awk -F'.' '{print $1}')
    elif [[ -e /etc/SuSE-release ]]; then
      majversion=$(head -n1 /etc/SuSE-release | awk -F' ' '{print $2}' | awk -F '.' '{print $1}')
    fi
  ;;
  Debian | debian)
    # Debian codenames: Squeeze=6, Wheezy=7, Jessie=8, Stretch=9, Buster=10, Bullseye=11, sid=experimental
    tmpversion=$(awk -F. '{print $1}' /etc/debian_version)
    if [[ ${tmpversion} = "6" ]] || [[ ${tmpversion} = "7" ]] || [[ ${tmpversion} = "8" ]] || [[ ${tmpversion} = "9" ]]; then
      majversion=${tmpversion}
    elif [[ ${tmpversion} = *queeze* ]]; then
      majversion=6
    elif [[ ${tmpversion} = *heezy* ]]; then
      majversion=7
    elif [[ ${tmpversion} = *essie* ]]; then
      majversion=8
    elif [[ ${tmpversion} = *tretch* ]]; then
      majversion=9
    elif [[ ${tmpversion} = *uster* ]]; then
      majversion=10
    elif [[ ${tmpversion} = *ullseye* ]]; then
      majversion=11
    fi
  ;;
  Ubuntu)
    majversion=$(grep -w ^DISTRIB_RELEASE /etc/lsb-release | awk -F'=' '{print $2}' | awk -F'.' '{print $1}')
  ;;
  *)
    if [[ -e /etc/os-release ]]; then
      majversion=$(grep -w ^VERSION /etc/os-release | awk -F'=' '{print $2}' | awk -F' ' '{print $1}' | tr -d '"' | awk -F'.' '{print $1}')
    else
      majversion="Unknown"
    fi
    ;;
esac
} #}}}

validate_distroversion() { #{{{
if [[ ${distro} = "Redhat" ]] || [[ ${distro} = "CentOS" ]] || [[ ${distro} = "Oracle" ]]; then
  if [[ ${majversion} = "5" ]] || [[ ${majversion} = "6" ]] || [[ ${majversion} = "7" ]]; then
    supportedver=true
  else
    supportedver=false
  fi
elif [[ ${distro} = *USE ]] || [[  ${distro} = "SLES" ]]; then # SLES or openSUSE
  if [[ ${majversion} = "11" ]] || [[ ${majversion} = "12" ]]; then
    supportedver=true
  else
    supportedver=false
  fi
elif [[ ${distro} = *ebian ]]; then # Debian or debian
  if [[ ${majversion} = "6" ]] || [[ ${majversion} = "7" ]] || [[ ${majversion} = "8" ]] || [[ ${majversion} = "9" ]]; then
    supportedver=true
  else
    supportedver=false
  fi
elif [[ ${distro} = "Ubuntu" ]]; then
  if [[ ${majversion} = "10" ]] || [[ ${majversion} = "14" ]] || [[ ${majversion} = "16" ]] || [[ ${majversion} = "18" ]]; then
    supportedver=true
  else
    supportedver=false
  fi
else
  supportedver=false
fi
} #}}}

get_arch() { #{{{
architecture=$(uname -m)
  if [[ ${architecture} = "x86_64" ]]; then
    host64=true
  elif [[ ${architecture} = i*86 ]]; then
    host64=false
  fi
} #}}}

validate_arch() { #{{{
if [[ ${architecture} = "x86_64" ]] || [[ ${architecture} = i*86 ]]; then
  case ${distro} in
    Redhat | CentOS | Oracle)
      if [[ ${majversion} = 5 && ${architecture} = "x86_64" ]] || [[ ${majversion} = 5 && ${architecture} = i*86 ]]; then
        supportedarch=true
      elif [[ ${majversion} = 6 && ${architecture} = "x86_64" ]] || [[ ${majversion} = 6 && ${architecture} = i*86 ]]; then
        supportedarch=true
      elif [[ ${majversion} = 7 && ${architecture} = "x86_64" ]]; then
        supportedarch=true
      else
        supportedarch=false
      fi
    ;;
    Debian | debian)
      if [[ ${supportedver} = true ]]; then
        supportedarch=true
      else
        supportedarch=false
      fi
      ;;
    SLES | openSUSE)
      if [[ ${supportedver} = true ]]; then
        supportedarch=true
      else
        supportedarch=false
      fi
    ;;
    Ubuntu)
      if [[ ${majversion} = 14 && ${architecture} = "x86_64" ]]; then
        supportedarch=true
      elif [[ ${majversion} = 16 && ${architecture} = "x86_64" ]]; then
        supportedarch=true
      elif [[ ${majversion} = 18 && ${architecture} = "x86_64" ]]; then
        supportedarch=true
      elif [[ ${majversion} = 10 && ${architecture} = "x86_64" ]] || [[ ${majversion} = 10 && ${architecture} = i*86 ]]; then
        supportedarch=true
      else
        supportedarch=false
      fi
      ;;
    *)
      if [[ ${architecture} = "x86_64" ]] || [[ ${architecture} = i*86 ]]; then
        supportedarch=true
      else
        supportedarch=false
      fi
      ;;
  esac
else
  echo -e "${f_red}This script is only for Intel/AMD x86 type architecture"
  echo -e "Script found ${architecture}, which is not supported.${reset}"
  exit 1
fi
} #}}}

select_package() { #{{{
if [[ ${supported_distro} = "true" ]] && [[ ${supportedver} = "true" ]] && [[ ${supportedarch} = "true" ]]; then
  case $distro in
  Redhat | CentOS)
    if [[ ${majversion} = 7 && ${architecture} = "x86_64" ]]; then
      installpkg=${rhel7_64}
    elif [[ ${majversion} = 6 && ${architecture} = "x86_64" ]]; then
      installpkg=${rhel6_64}
    elif [[ ${majversion} = 6 && ${architecture} = i*86 ]]; then
      installpkg=${rhel6_32}
    elif [[ ${majversion} = 5 && ${architecture} = "x86_64" ]];then
      installpkg=${rhel5_64}
    else [[ ${majversion} = 5 && ${architecture} = i*86 ]]
      installpkg=${rhel5_32}
    fi
  ;;
  Oracle)
    if [[ ${majversion} = 7 && ${architecture} = "x86_64" ]]; then
      installpkg=${oracle7_64}
    elif [[ ${majversion} = 6 && ${architecture} = "x86_64" ]]; then
      installpkg=${oracle6_64}
    elif [[ ${majversion} = 6 && ${architecture} = i*86 ]]; then
      installpkg=${oracle6_32}
    elif [[ ${majversion} = 5 && ${architecture} = "x86_64" ]];then
      installpkg=${oracle5_64}
    else [[ ${majversion} = 5 && ${architecture} = i*86 ]]
      installpkg=${oracle5_32}
    fi
  ;;
  SLES | openSUSE)
    if [[ ${majversion} = 12 && ${architecture} = "x86_64" ]]; then
      installpkg=${suse12_64}
    elif [[ ${majversion} = 12 && ${architecture} = i*86 ]]; then
      installpkg=${suse12_32}
    elif [[ ${majversion} = 11 && ${architecture} = "x86_64" ]]; then
      installpkg=${suse11_64}
    else [[ ${majversion} = 11 && ${architecture} = i*86 ]]
      installpkg=${suse11_32}
    fi
  ;;
  Debian | debian)
    if [[ ${majversion} = 9 && ${architecture} = "x86_64" ]]; then
      installpkg=${debian9_64}
    elif [[ ${majversion} = 9 && ${architecture} = i*86 ]]; then
      installpkg=${debian9_32}
    elif [[ ${majversion} = 8 && ${architecture} = "x86_64" ]]; then
      installpkg=${debian8_64}
    elif [[ ${majversion} = 8 && ${architecture} = i*86 ]]; then
      installpkg=${debian8_32}
    elif [[ ${majversion} = 7 && ${architecture} = "x86_64" ]]; then
      installpkg=${debian67_64}
    elif [[ ${majversion} = 7 && ${architecture} = i*86 ]]; then
      installpkg=${debian67_32}
    elif [[ ${majversion} = 6 && ${architecture} = "x86_64" ]]; then
      installpkg=${debian67_64}
    else [[ ${majversion} = 6 && ${architecture} = i*86 ]]
      installpkg=${debian67_32}
    fi
  ;;
  Ubuntu)
    if [[ ${majversion} = 18 ]]; then
      installpkg=${ubuntu18_64}
    elif [[ ${majversion} = 16 ]]; then
      installpkg=${ubuntu16_64}
    elif [[ ${majversion} = 14 ]]; then
      installpkg=${ubuntu14_64}
    elif [[ ${majversion} = 10 && ${architecture} = "x86_64" ]]; then
      installpkg=${ubuntu10_64}
    else [[ ${majversion} = 10 && ${architecture} = i*86 ]]
      installpkg=${ubuntu10_32}
    fi
  ;;
esac
else
  echo -e "${f_red}Not a supported configuration, exiting${reset}"
  exit 1
fi
} #}}}

validate_package(){ #{{{
installer=$0
case ${installer} in
  ./InstallTaniumRHEL.sh)
    if [[ -e ${installpkg} ]]; then
      pkg_exists=true
    else
      echo -e "${f_red}Install package ${installpkg} not found in directory, exiting${reset}"
      exit 1
    fi
    if [[ -e ${taniumpub} ]]; then
      pub_exists=true
    else
      echo -e "${f_red}Install pub ${taniumpub} not found in directory, exiting${reset}"
      exit 1
    fi
  ;;
  ./InstallTaniumOracle.sh)
    if [[ -e ${installpkg} ]]; then
      pkg_exists=true
    else
      echo -e "${f_red}Install package ${installpkg} not found in directory, exiting${reset}"
      exit 1
    fi
    if [[ -e ${taniumpub} ]]; then
      pub_exists=true
    else
      echo -e "${f_red}Install pub ${taniumpub} not found in directory, exiting${reset}"
      exit 1
    fi
  ;;
  ./InstallTaniumSUSE.sh)
    if [[ -e ${installpkg} ]]; then
      pkg_exists=true
    else
      echo -e "${f_red}Install package ${installpkg} not found in directory, exiting${reset}"
      exit 1
    fi
    if [[ -e ${taniumpub} ]]; then
      pub_exists=true
    else
      echo -e "${f_red}Install pub ${taniumpub} not found in directory, exiting${reset}"
      exit 1
    fi
  ;;
  ./InstallTaniumDebian.sh)
    if [[ -e ${installpkg} ]]; then
      pkg_exists=true
    else
      echo -e "${f_red}Install package ${installpkg} not found in directory, exiting${reset}"
      exit 1
    fi
    if [[ -e ${taniumpub} ]]; then
      pub_exists=true
    else
      echo -e "${f_red}Install pub ${taniumpub} not found in directory, exiting${reset}"
      exit 1
    fi
  ;;
  ./InstallTaniumUbuntu.sh)
    if [[ -e ${installpkg} ]]; then
      pkg_exists=true
    else
      echo -e "${f_red}Install package ${installpkg} not found in directory, exiting${reset}"
      exit 1
    fi
    if [[ -e ${taniumpub} ]]; then
      pub_exists=true
    else
      echo -e "${f_red}Install pub ${taniumpub} not found in directory, exiting${reset}"
      exit 1
    fi
  ;;
  * )
    echo -e "${f_red}Unrecognized install script ${installer}, exiting${reset}"
    exit 1
esac

} #}}}

get_domain() { #{{{
tmpdomain=$(hostname -d | awk -F'.' '{print $1}')
if [[ -z ${tmpdomain} ]]; then
  domain=${tmpdomain^^} # not supported in bash < 4
else
  domain=Unconfigured
fi 
} #}}}

show_banner() { #{{{
echo -e "${f_green}\n"
echo -e '      _________    _   ________  ____  ___'
echo -e '     /_  __/   |  / | / /  _/ / / /  |/  /'
echo -e '      / / / /| | /  |/ // // / / / /|_/ /'
echo -e '     / / / ___ |/ /|  // // /_/ / /  / /'
echo -e '    /_/ /_/  |_/_/ |_/___/\____/_/  /_/'
echo -e "${reset}\n"
if [[ ${supported_distro} = "true" ]] && [[ ${supportedver} = "true" ]] && [[ ${supportedarch} = "true" ]] && [[ ${pkg_exists} = "true" ]] && [[ ${pub_exists} = "true" ]]; then
  echo -e "Found distribution: ${distro}"
  echo -e "Supported distro: ${supported_distro}"
  echo -e "Found version: ${majversion}"
  echo -e "Supported version: ${supportedver}"
  echo -e "Found architecture: ${architecture}"
  echo -e "Supported architecture: ${supportedarch}"
  echo -e "Found install package: ${installpkg}"
  echo -e "Found Tanium key file: ${taniumpub}"
# echo -e "Suggest agency is ${domain}"
  echo -e "${f_green}This is a supported configuration, continuing...${reset}\n"
else
  echo -e "${f_red}This is NOT a supported configuration, exiting.${reset}"
  exit 1
fi
} #}}}

prompt_agency() { #{{{
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
read response
case ${response} in
 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 19)
   serverip=${publicserverip}
   ;;
 18)
   serverip=${oitserverip}
   ;;
 *)
   echo -e "${f_red}That is not a valid agency number, exiting.${reset}"
   exit 1
   ;;
esac

if [ ${response} -eq 1 ]
 then agency="CDA"
elif [ ${response} -eq 2 ]
 then agency="CDHS"
elif [ ${response} -eq 3 ]
 then agency="CDLE"
elif [ ${response} -eq 4 ]
 then agency="CDOT"
elif [ ${response} -eq 5 ]
 then agency="CDPHE"
elif [ ${response} -eq 6 ]
 then agency="CDPS"
elif [ ${response} -eq 7 ]
 then agency="CHS"
elif [ ${response} -eq 8 ]
 then agency="CST"
elif [ ${response} -eq 9 ]
 then agency="DMVA"
elif [ ${response} -eq 10 ]
 then agency="DNR"
elif [ ${response} -eq 11 ]
 then agency="DOC"
elif [ ${response} -eq 12 ]
 then agency="DOLA"
elif [ ${response} -eq 13 ]
 then agency="DOR"
elif [ ${response} -eq 14 ]
 then agency="DORA"
elif [ ${response} -eq 15 ]
 then agency="DPA"
elif [ ${response} -eq 16 ]
 then agency="GOV"
elif [ ${response} -eq 17 ]
 then agency="HCPF"
elif [ ${response} -eq 18 ]
 then agency="OIT"
elif [ ${response} -eq 19 ]
 then agency="OITEDIT"
fi
} #}}}

install_package() { #{{{
case ${distro} in
 Redhat | CentOS | Oracle | SLES | openSUSE)
  echo -e "Installing Tanium client for ${distro}, version ${majversion}"
  rpm -ivh ${installpkg}
  sleep 5
;;
 Debian | debian | Ubuntu)
  echo -e "Installing Tanium client for ${distro}, version ${majversion}"
  dpkg -i ${installpkg}
  sleep 5
;;
 *)
  echo -e "${f_red}Unrecognized distro, exiting. ${distro}${reset}"
  exit 1
;;
esac
} # }}}

configure_tanium() { #{{{
if [[ ${pub_exists} = "true" ]]; then
  echo -e "Installing pub file: ${f_green}${taniumpub}${reset}"
  cp ${taniumpub} /opt/Tanium/TaniumClient/
elif [[ ${pub_exists} = "false" ]]; then
  echo -e "${f_red}Tanium public key not found, exiting.${reset}"
  exit 1
fi
echo -e "Setting Tanium parameters:"
echo -e "  Tanium server IP: ${f_green}${serverip}${reset}"
/opt/Tanium/TaniumClient/TaniumClient config set ServerNameList ${serverip}
echo -e "  Tanium server port: ${f_green}${taniumport}${reset}"
/opt/Tanium/TaniumClient/TaniumClient config set taniumport ${taniumport}
echo -e "  Tanium log verbosity level: ${f_green}${verbosity}${reset}"
/opt/Tanium/TaniumClient/TaniumClient config set LogVerbosityLevel ${verbosity}
echo -e "Setting Agency custom tag to: ${f_green}${agency}${reset}"
if [ -d /opt/Tanium/TaniumClient/Tools ]
 then
  echo -e "~~${agency}" > /opt/Tanium/TaniumClient/Tools/CustomTags.txt
 else
  mkdir /opt/Tanium/TaniumClient/Tools
  echo -e "~~${agency}" > /opt/Tanium/TaniumClient/Tools/CustomTags.txt
fi
} #}}}

start_services() { #{{{
case ${distro} in
 Redhat | CentOS | Oracle)
  if [[ ${majversion} = "5" ]] || [[ ${majversion} = "6" ]]; then
   echo -e "Starting Tanium service"
   service TaniumClient start
   chkconfig --level 2345 TaniumClient on
  elif [[ ${majversion} = "7" ]]; then
   echo -e "Starting Tanium service"
    systemctl start taniumclient
    systemctl enable taniumclient
  fi
 ;;
 SUSE | openSUSE)
  echo -e "Starting Tanium service"
  service TaniumClient start
  chkconfig --level 2345 TaniumClient on
 ;;
 Debian | debian)
  if [[ ${majversion} = "6" ]] || [[ ${majversion} = "7" ]]; then
   echo -e "Starting Tanium service"
   service TaniumClient start
   chkconfig --level 2345 TaniumClient on
  elif [[ ${majversion} = "8" ]] || [[ ${majversion} = "9" ]]; then
   echo -e "Starting Tanium Service"
   systemctl start taniumclient
   systemctl enable taniumclient
  fi
 ;;
 Ubuntu)
  if [[ ${majversion} = "10" ]] || [[ ${majversion} = "14" ]]; then
   echo -e "Starting Tanium service"
   service TaniumClient start
   chkconfig --level 2345 TaniumClient on
  elif [[ ${majversion} = "16" ]] || [[ ${majversion} = "18" ]]; then
   echo -e "Starting Tanium Service"
   systemctl start taniumclient
   systemctl enable taniumclient
  fi
 ;;
esac
} #}}}

final_message() { #{{{
echo -e "${F_GREEN}Install Complete${RESET}"
echo -e "${F_RED}Please verify that firewall port ${SERVERPORT}/TCP is open to ${SERVERIP}${RESET}"
exit 0
} #}}}

# BEGIN PROCESSING
# check_root
get_distro
get_distroversion
validate_distroversion
get_arch
validate_arch
# get_domain - UNUSED FOR NOW
select_package
validate_package
show_banner
prompt_agency
# install_package
# configure_tanium
# start_services
# final_message
exit 0
