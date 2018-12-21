#!/bin/bash
# Script to install supported Linux Tanium clients
# Kevin Burg - kevin.burg@state.co.us

f_red="\e[38;2;255;0;0m"
f_green="\e[38;2;0;255;0m"
reset="\e[0m"

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

if [[ -e /etc/os-release ]]; then
  distro=$(grep ^NAME /etc/os-release | awk -F'=' '{print $2}' | awk -F' ' '{print $1}' | tr -d '"')
  case ${distro} in
  CentOS | Oracle | SUSE | openSUSE | Debian | debian | Ubuntu)
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
else
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
  CentOS | Oracle | SUSE | openSUSE | Redhat)
    majversion=$(grep -w ^VERSION /etc/os-release | awk -F'=' '{print $2}' | awk -F' ' '{print $1}' | tr -d '"' | awk -F'.' '{print $1}')
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
elif [[ ${distro} = "SUSE" ]] || [[ ${distro} = "openSUSE" ]]; then
  if [[ ${majversion} = "11" ]] || [[ ${majversion} = "12" ]]; then
    supportedver=true
  else
    supportedver=false
  fi
elif [[ ${distro} = *ebian ]]; then
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
  SUSE | openSUSE)
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
esac
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
# validate_arch
get_domain
# show_banner
echo -e "Found distribution: ${distro}"
echo -e "Found version: ${majversion}"
echo -e "Found architecture: ${architecture}"
# echo -e "Suggest agency is ${DOMAIN}"
if [[ ${supported_distro} = "true" ]] && [[ ${supportedver} = "true" ]]; then
 echo -e "${f_green}This is a supported configuration${reset}"
 else
 echo -e "${f_red}This is NOT a supported configuration${reset}"
fi
exit 0
