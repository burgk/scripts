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
taniumpub="tanium.pub"
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
  CentOS | Oracle | SUSE | SLES | openSUSE | Debian | debian | Ubuntu)
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
  CentOS | Oracle | SUSE | SLES | openSUSE | Redhat)
    majversion=$(grep -w ^VERSION_ID /etc/os-release | awk -F'=' '{print $2}' | awk -F' ' '{print $1}' | tr -d '"' | awk -F'.' '{print $1}')
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
elif [[ ${distro} = *USE ]] || [[  ${distro} = "SLES" ]]; then # SUSE or openSUSE
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
    SUSE | SLES | openSUSE)
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
  SUSE | SLES | openSUSE)
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

get_domain() { #{{{
 tmpdomain=$(hostname -d | awk -F'.' '{print $1}')
 domain=${tmpdomain^^}
} #}}}

show_banner() { #{{{
echo -e "${f_green}\n"
echo -e '      _________    _   ________  ____  ___'
echo -e '     /_  __/   |  / | / /  _/ / / /  |/  /'
echo -e '      / / / /| | /  |/ // // / / / /|_/ /'
echo -e '     / / / ___ |/ /|  // // /_/ / /  / /'
echo -e '    /_/ /_/  |_/_/ |_/___/\____/_/  /_/'
echo -e "${reset}\n"
} #}}}

# check_root
get_distro
get_distroversion
validate_distroversion
get_arch
validate_arch
get_domain
select_package
# show_banner
echo -e "Found distribution: ${distro}"
echo -e "Supported distro: ${supported_distro}"
echo -e "Found version: ${majversion}"
echo -e "Supported version: ${supportedver}"
echo -e "Found architecture: ${architecture}"
echo -e "Supported arch: ${supportedarch}"
# echo -e "Suggest agency is ${domain}"
if [[ ${supported_distro} = "true" ]] && [[ ${supportedver} = "true" ]] && [[ ${supportedarch} = "true" ]]; then
  echo -e "${f_green}This is a supported configuration${reset}"
  echo -e "Will install ${installpkg}"
else
  echo -e "${f_red}This is NOT a supported configuration${reset}"
fi
exit 0
