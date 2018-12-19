#!/bin/bash
# Script to install supported Linux Tanium clients
# Kevin Burg - kevin.burg@state.co.us

f_red="\e[38;2;255;0;0m"
f_green="\e[38;2;0;255;0m"
reset="\e[0m"

check_root() {
 if (( ${EUID} != 0 )); then
  echo -e "${f_red}You need to be root or use sudo to run this script"
  echo -e "For example: sudo ./$(basename ${0})${reset}"
  exit 1
 fi
}

query_distro() {
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
   if [[ ${distro} = "debian" ]] || [[ ${distro} = "Debian" ]]; then
     supported_distro=true
   else
     supported_distro=false
   fi
fi
}

get_arch() {
 architecture=$(uname -m)
 if [[ ${architecture} = "x86_64" ]]; then
  host64=true
 elif [[ ${architecture} = "i?86" ]]; then
  host64=false
 fi
}

probe_version() {
case ${distro} in
  CentOS | Oracle | SUSE | openSUSE | Redhat)
    majversion=$(grep -w ^VERSION /etc/os-release | awk -F'=' '{print $2}' | awk -F' ' '{print $1}' | tr -d '"' | awk -F'.' '{print $1}')
  ;;
  Debian | debian)
    majversion=$(awk -F. '{print $1}' /etc/debian_version)
  ;;
  Ubuntu)
    majversion=$(grep -w ^DISTRIB_RELEASE /etc/lsb-release | awk -F'=' '{print $2}' | awk -F'.' '{print $1}')
  ;;
  *)
    if [[ -e /etc/os-release ]]; then
      majversion=$(grep -w ^VERSION /etc/os-release | awk -F'=' '{print $2}' | awk -F' ' '{print $1}' | tr -d '"' | awk -F'.' '{print $1}')
    else
      majversion="Unable to determine version of ${distro}"
    fi
    ;;
esac
}

validate_version() {
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
 elif [[ ${distro} = "Debian" ]] || [[ ${distro} = "debian" ]]; then
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
}

get_domain() {
 tmpdomain=$(hostname -d | awk -F'.' '{print $1}')
 domain=${tmpdomain^^}
}

banner_print() {
echo -e "${f_green}\n"
echo -e '      _________    _   ________  ____  ___'
echo -e '     /_  __/   |  / | / /  _/ / / /  |/  /'
echo -e '      / / / /| | /  |/ // // / / / /|_/ /'
echo -e '     / / / ___ |/ /|  // // /_/ / /  / /'
echo -e '    /_/ /_/  |_/_/ |_/___/\____/_/  /_/'
echo -e "${reset}\n"
}

# check_root
query_distro
probe_version
get_arch
get_domain
validate_version
# banner_print
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
