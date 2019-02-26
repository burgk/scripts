#!/bin/bash
# Script to install supported Linux Tanium clients
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definions #{{{
# oitserverip=10.51.2.112
oitserverip="10.51.50.101"
publicserverip="165.127.219.171"
taniumport="17472"
taniumport2="17444"
verbosity="0"
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
ubuntu10_32="./taniumclient_6.0.314.1579-ubuntu10_i386.deb"
ubuntu10_64="./taniumclient_6.0.314.1579-ubuntu10_amd64.deb"
ubuntu14_64="./taniumclient_7.2.314.3476-ubuntu14_amd64.deb"
ubuntu16_64="./taniumclient_7.2.314.3476-ubuntu16_amd64.deb"
ubuntu18_64="./taniumclient_7.2.314.3476-ubuntu18_amd64.deb"
aws2_64="./TaniumClient-7.2.314.3476-1.amzn2.x86_64.rpm"
aws2018_03_64="./TaniumClient-7.2.314.3476-1.amzn2018.03.x86_64.rpm"
aws2017_09_64="./TaniumClient-7.2.314.3211-1.amzn2017.09.x86_64.rpm"
aws2017_12_64="./TaniumClient-7.2.314.3211-1.amzn2017.12.x86_64.rpm"
#}}}

check_root() { #{{{
if (( ${EUID} != 0 )); then
  echo -e "${f_red}You need to be use sudo or be root to run this script"
  echo -e "For example: sudo ./$(basename ${0})${reset}"
  exit 1
 fi
} #}}}

get_distro() { #{{{
operatingsystem=$(uname -o)
if [[ ${operatingsystem} != *inux* ]]; then
  echo -e "${f_red}In function get_distro: This script is only designed to work with Linux hosts"
  echo -e "It found ${operatingsystem} instead and cannot continue.${reset}"
  exit 1
fi

if [[ -e /etc/os-release ]]; then # Should get most supported systems
  distro=$(grep ^NAME /etc/os-release | awk -F'=' '{print $2}' | awk -F' ' '{print $1}' | tr -d '"')
  case ${distro} in
  CentOS | Oracle | SLES | openSUSE | Debian | debian | Ubuntu | Amazon)
    supported_distro="true"
    return
  ;;
  Red)
    distro="Redhat"
    supported_distro="true"
    return
  ;;
  *)
    supported_distro="false"
    return
  ;;
  esac
elif [[ -e /etc/oracle-release ]]; then # Get old Oracle
  distro="Oracle"
  supported_distro="true"
  return
elif [[ -e /etc/centos-release ]]; then # Get old CentOS
  distro="CentOS"
  supported_distro="true"
  return
elif [[ -e /etc/redhat-release ]]; then # Get old Redhat
  distro="Redhat"
  supported_distro="true"
  return
elif [[ -e /etc/lsb-release ]]; then # Gets old Ubuntu
  distro=$(grep DISTRIB_ID /etc/lsb-release | awk -F'=' '{print $2}' | tr -d '"')
  if [[ ${distro} = *buntu* ]]; then
    supported_distro="true"
    return
  else
    supported_distro="false"
    return
  fi
elif [[ -e /etc/SuSE-release ]]; then # Gets old openSuse
  distro=$(head -n1 /etc/SuSE-release | awk -F' ' '{print $1}')
  if [[ ${distro} = "openSUSE" ]]; then
    supported_distro="true"
    return
  else
    supported_distro="false"
    return
  fi
elif [[ -e /etc/debian_version ]]; then # Gets old Debian
  distro="Debian"
  supported_distro="true"
  return
else # Unsupported distro
  echo -e "${f_red}In function get_distro: Unable to determine Linux distribution, exiting${reset}"
  exit 1
fi
} #}}}

get_distroversion() { #{{{
case ${distro} in
  CentOS | Oracle | SLES | openSUSE | Redhat)
    if [[ -e /etc/os-release ]]; then
      majversion=$(grep -w ^VERSION_ID /etc/os-release | awk -F'=' '{print $2}' | awk -F' ' '{print $1}' | tr -d '"' | awk -F'.' '{print $1}')
    elif [[ -e /etc/oracle-release ]]; then # Get old Oracle version
      majversion=$(awk -F' ' '{print $5}' /etc/oracle-release | awk -F'.' '{print $1}')
    elif [[ -e /etc/centos-release ]]; then # Get old CentOS version
      majversion=$(awk -F' ' '{print $5}' /etc/centos-release | awk -F'.' '{print $1}')
    elif [[ -e /etc/redhat-release ]]; then # Get old Redhat version
      majversion=$(awk -F' ' '{print $7}' /etc/redhat-release | awk -F'.' '{print $1}')
    elif [[ -e /etc/SuSE-release ]]; then # Get old openSUSE
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
  Amazon)
    majversion=$(grep -w ^VERSION_ID /etc/os-release | awk -F'=' '{print $2}' | tr -d '"')
  ;;
esac
} #}}}

validate_distroversion() { #{{{
if [[ ${distro} = "Redhat" ]] || [[ ${distro} = "CentOS" ]] || [[ ${distro} = "Oracle" ]]; then
  if [[ ${majversion} = "5" ]] || [[ ${majversion} = "6" ]] || [[ ${majversion} = "7" ]]; then
    supportedver="true"
    return
  else
    echo -e "${f_red}"
    echo -e "Error: In function validate_distroversion"
    echo -e "Found distro: ${distro}" 
    echo -e "Found major version: ${majversion}"
    echo -e "This is not a supported combination, exiting."
    echo -e "${reset}"
    exit 1
  fi
elif [[ ${distro} = *USE ]] || [[  ${distro} = "SLES" ]]; then # SLES or openSUSE
  if [[ ${majversion} = "11" ]] || [[ ${majversion} = "12" ]]; then
    supportedver="true"
    return
  else
    echo -e "${f_red}"
    echo -e "Error: In function validate_distroversion"
    echo -e "Found distro: ${distro}" 
    echo -e "Found major version: ${majversion}"
    echo -e "This is not a supported combination, exiting."
    echo -e "${reset}"
    exit 1
  fi
elif [[ ${distro} = *ebian ]]; then # Debian or debian
  if [[ ${majversion} = "6" ]] || [[ ${majversion} = "7" ]] || [[ ${majversion} = "8" ]] || [[ ${majversion} = "9" ]]; then
    supportedver="true"
    return
  else
    echo -e "${f_red}"
    echo -e "Error: In function validate_distroversion"
    echo -e "Found distro: ${distro}" 
    echo -e "Found major version: ${majversion}"
    echo -e "This is not a supported combination, exiting."
    echo -e "${reset}"
    exit 1
  fi
elif [[ ${distro} = "Ubuntu" ]]; then
  if [[ ${majversion} = "10" ]] || [[ ${majversion} = "14" ]] || [[ ${majversion} = "16" ]] || [[ ${majversion} = "18" ]]; then
    supportedver="true"
    return
  fi
elif [[ ${distro} = "Amazon" ]]; then
  if [[ ${majversion} = "2" ]] || [[ ${majversion} = "2018.03" ]] || [[ ${majversion} = "2017.09" ]] || [[ ${majversion} = "2017.12" ]]; then
    supportedver="true"
    return
  else
    echo -e "${f_red}"
    echo -e "Error: In function validate_distroversion"
    echo -e "Found distro: ${distro}" 
    echo -e "Found major version: ${majversion}"
    echo -e "This is not a supported combination, exiting."
    echo -e "${reset}"
    exit 1
  fi
else
  supportedver="false"
  return
fi
} #}}}

get_arch() { #{{{
architecture=$(uname -m)
if [[ ${architecture} = "x86_64" ]]; then
  host64="true"
elif [[ ${architecture} = i*86 ]]; then
  host64="false"
else
  echo -e "${f_red}In function get_arch: This script is only for Intel/AMD x86 type architecture"
  echo -e "Script found ${architecture}, which is not supported.${reset}"
  exit 1
fi
} #}}}

validate_arch() { #{{{
case ${distro} in
  Redhat | CentOS | Oracle)
    if [[ ${majversion} = 5 && ${host64} = "true" ]] || [[ ${majversion} = 5 && ${host64} = "false" ]]; then
      supportedarch="true"
    elif [[ ${majversion} = 6 && ${host64} = "true" ]] || [[ ${majversion} = 6 && ${host64} = "false" ]]; then
      supportedarch="true"
    elif [[ ${majversion} = 7 && ${host64} = "true" ]]; then
      supportedarch="true"
    else
      supportedarch="false"
    fi
  ;;
  Debian | debian)
    if [[ ${supportedver} = "true" ]]; then
      supportedarch="true"
    else
      supportedarch="false"
    fi
    ;;
  SLES | openSUSE)
    if [[ ${supportedver} = "true" ]]; then
      supportedarch="true"
    else
      supportedarch="false"
    fi
  ;;
  Ubuntu)
    if [[ ${majversion} = 14 && ${host64} = "true" ]]; then
      supportedarch="true"
    elif [[ ${majversion} = 16 && ${host64} = "true" ]]; then
      supportedarch="true"
    elif [[ ${majversion} = 18 && ${host64} = "true" ]]; then
      supportedarch="true"
    elif [[ ${majversion} = 10 && ${host64} = "true" ]] || [[ ${majversion} = 10 && ${host64} = "false" ]]; then
      supportedarch="true"
    else
      supportedarch="false"
    fi
    ;;
  Amazon)
    if [[ ${majversion} = "2" && ${host64} = "true" ]]; then
      supportedarch="true"
    elif [[ ${majversion} = "2018.03" && ${host64} = "true" ]]; then
      supportedarch="true"
    elif [[ ${majversion} = "2017.09" && ${host64} = "true" ]]; then
      supportedarch="true"
    elif [[ ${majversion} = "2017.12" && ${host64} = "true" ]]; then
      supportedarch="true"
    else
      supportedarch="false"
    fi
    ;;
  *)
    if [[ ${host64} = "true" ]] || [[ ${host64} = "false" ]]; then
      supportedarch="true"
    else
      supportedarch="false"
    fi
    ;;
esac
} #}}}

select_package() { #{{{
if [[ ${supported_distro} = "true" ]] && [[ ${supportedver} = "true" ]] && [[ ${supportedarch} = "true" ]]; then
  case $distro in
  Redhat | CentOS)
    if [[ ${majversion} = 7 && ${host64} = "true" ]]; then
      installpkg=${rhel7_64}
      installmethod="systemd"
      clientname="taniumclient"
    elif [[ ${majversion} = 6 && ${host64} = "true" ]]; then
      installpkg=${rhel6_64}
      installmethod="svc"
      clientname="TaniumClient"
    elif [[ ${majversion} = 6 && ${host64} = "false" ]]; then
      installpkg=${rhel6_32}
      installmethod="svc"
      clientname="TaniumClient"
    elif [[ ${majversion} = 5 && ${host64} = "true" ]];then
      installpkg=${rhel5_64}
      installmethod="svc"
      clientname="TaniumClient"
    else [[ ${majversion} = 5 && ${host64} = "false" ]]
      installpkg=${rhel5_32}
      installmethod="svc"
      clientname="TaniumClient"
    fi
  ;;
  Oracle)
    if [[ ${majversion} = 7 && ${host64} = "true" ]]; then
      installpkg=${oracle7_64}
      installmethod="systemd"
      clientname="taniumclient"
    elif [[ ${majversion} = 6 && ${host64} = "true" ]]; then
      installpkg=${oracle6_64}
      installmethod="svc"
      clientname="TaniumClient"
    elif [[ ${majversion} = 6 && ${host64} = "false" ]]; then
      installpkg=${oracle6_32}
      installmethod="svc"
      clientname="TaniumClient"
    elif [[ ${majversion} = 5 && ${host64} = "true" ]];then
      installpkg=${oracle5_64}
      installmethod="svc"
      clientname="TaniumClient"
    else [[ ${majversion} = 5 && ${host64} = "false" ]]
      installpkg=${oracle5_32}
      installmethod="svc"
      clientname="TaniumClient"
    fi
  ;;
  SLES | openSUSE)
    if [[ ${majversion} = 12 && ${host64} = "true" ]]; then
      installpkg=${suse12_64}
      clientname="taniumclient"
      installmethod="systemd"
    elif [[ ${majversion} = 12 && ${host64} = "false" ]]; then
      installpkg=${suse12_32}
      clientname="taniumclient"
      clientname="taniumclient"
    elif [[ ${majversion} = 11 && ${host64} = "true" ]]; then
      installpkg=${suse11_64}
      clientname="taniumclient"
      installmethod="svc"
    else [[ ${majversion} = 11 && ${host64} = "false" ]]
      installpkg=${suse11_32}
      clientname="taniumclient"
      installmethod="svc"
    fi
  ;;
  Debian | debian)
    if [[ ${majversion} = 9 && ${host64} = "true" ]]; then
      installpkg=${debian9_64}
      installmethod="systemd"
      clientname="taniumclient"
    elif [[ ${majversion} = 9 && ${host64} = "false" ]]; then
      installpkg=${debian9_32}
      installmethod="systemd"
      clientname="taniumclient"
    elif [[ ${majversion} = 8 && ${host64} = "true" ]]; then
      installpkg=${debian8_64}
      installmethod="systemd"
      clientname="taniumclient"
    elif [[ ${majversion} = 8 && ${host64} = "false" ]]; then
      installpkg=${debian8_32}
      installmethod="systemd"
      clientname="taniumclient"
    elif [[ ${majversion} = 7 && ${host64} = "true" ]]; then
      installpkg=${debian67_64}
      installmethod="svc"
      clientname="taniumclient"
    elif [[ ${majversion} = 7 && ${host64} = "false" ]]; then
      installpkg=${debian67_32}
      installmethod="svc"
      clientname="taniumclient"
    elif [[ ${majversion} = 6 && ${host64} = "true" ]]; then
      installpkg=${debian67_64}
      installmethod="svc"
      clientname="taniumclient"
    else [[ ${majversion} = 6 && ${host64} = "false" ]]
      installpkg=${debian67_32}
      installmethod="svc"
      clientname="taniumclient"
    fi
  ;;
  Ubuntu)
    if [[ ${majversion} = 18 ]]; then
      installpkg=${ubuntu18_64}
      installmethod="systemd"
      clientname="taniumclient"
    elif [[ ${majversion} = 16 ]]; then
      installpkg=${ubuntu16_64}
      installmethod="systemd"
      clientname="taniumclient"
    elif [[ ${majversion} = 14 ]]; then
      installpkg=${ubuntu14_64}
      installmethod="svc"
      clientname="taniumclient"
    elif [[ ${majversion} = 10 && ${host64} = "true" ]]; then
      installpkg=${ubuntu10_64}
      installmethod="svc"
      clientname="taniumclient"
      taniumini="true"
    else [[ ${majversion} = 10 && ${host64} = "false" ]]
      installpkg=${ubuntu10_32}
      installmethod="svc"
      clientname="taniumclient"
      taniumini="true"
    fi
  ;;
  Amazon)
    if [[ ${majversion} = "2" && ${host64} = "true" ]]; then
      installpkg=${aws2_64}
      installmethod="svc"
      clientname="TaniumClient"
    elif [[ ${majversion} = "2018.03" && ${host64} = "true" ]]; then
      installpkg=${aws2018_03_64}
      installmethod="svc"
      clientname="TaniumClient"
    elif [[ ${majversion} = "2017.09" && ${host64} = "true" ]]; then
      installpkg=${aws2017_09_64}
      installmethod="svc"
      clientname="TaniumClient"
    elif [[ ${majversion} = "2017.12" && ${host64} = "true" ]]; then
      installpkg=${aws2017_12_64}
      installmethod="svc"
      clientname="TaniumClient"
    fi
    ;;
esac
else
  echo -e "${f_red}"
  echo -e "Error: In function select_package"
  echo -e "Found distro: ${distro}"
  echo -e "Found major version: ${majversion}"
  echo -e "Found architecture: ${architecture}"
  echo -e "Not a supported configuration"
  echo -e "${reset}"
  exit 1
fi
} #}}}

validate_package(){ #{{{
if [[ -e ${installpkg} ]]; then
  pkg_exists="true"
else
  echo -e "${f_red}In function validate_package: Install package ${installpkg} not found in directory, exiting${reset}"
  exit 1
fi
if [[ -e ${taniumpub} ]]; then
  pub_exists="true"
else
  echo -e "${f_red}In function validate_package: Install pub ${taniumpub} not found in directory, exiting${reset}"
  exit 1
fi
} #}}}

get_domain() { #{{{
tmpdomain=$(hostname -d | awk -F'.' '{print $1}')
if [[ -z ${tmpdomain} ]]; then
  domain=${tmpdomain^^} # not supported in bash < 4
else
  domain="Unconfigured"
fi 
} #}}}

get_args() { #{{{
  silentinstall="true"
  timestamp=$(date +%s)
  touch "./install-tanium-${timestamp}.log"
  logfile="./install-tanium-${timestamp}.log"
  case $1 in
  1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19)
    cliarg=$1
    ;;
  *)
    echo -e "${f_red}In function get_args: Not a valid agency, exiting.${reset}" >> "${logfile}"
    exit 1
    ;;
  esac
} #}}}

show_banner() { #{{{
if [[ ${silentinstall} = "true" ]]; then
  if [[ ${supported_distro} = "true" ]] && [[ ${supportedver} = "true" ]] && [[ ${supportedarch} = "true" ]] && [[ ${pkg_exists} = "true" ]] && [[ ${pub_exists} = "true" ]]; then
    echo -e "Found distribution: ${distro}" >> "${logfile}"
    echo -e "Supported distro: ${supported_distro}" >> "${logfile}"
    echo -e "Found version: ${majversion}" >> "${logfile}"
    echo -e "Supported version: ${supportedver}" >> "${logfile}"
    echo -e "Found architecture: ${architecture}" >> "${logfile}"
    echo -e "Supported architecture: ${supportedarch}" >> "${logfile}"
    echo -e "Found install package: ${installpkg}" >> "${logfile}"
    echo -e "Found Tanium key file: ${taniumpub}" >> "${logfile}"
  else
    echo -e "In function show_banner: This is not a supported configuration, exiting." >> "${logfile}"
    exit 1
  fi
else
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
    echo -e "${f_green}This is a supported configuration, continuing...${reset}\n"
  else
    echo -e "${f_red}In function show_banner: This is NOT a supported configuration, exiting.${reset}"
    exit 1
  fi
fi
} #}}}

prompt_agency() { #{{{
if [[ ${silentinstall} = "true" ]]; then
  response=${cliarg}
else
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
fi
case ${response} in
  1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 19)
    serverip=${publicserverip}
  ;;
  18)
    serverip=${oitserverip}
  ;;
  *)
    echo -e "${f_red}In function prompt_agency: That is not a valid agency number, exiting.${reset}"
    exit 1
  ;;
esac

if [ ${response} -eq 1 ]; then
  agency="CDA"
elif [ ${response} -eq 2 ]; then
  agency="CDHS"
elif [ ${response} -eq 3 ]; then
  agency="CDLE"
elif [ ${response} -eq 4 ]; then
  agency="CDOT"
elif [ ${response} -eq 5 ]; then
  agency="CDPHE"
elif [ ${response} -eq 6 ]; then
  agency="CDPS"
elif [ ${response} -eq 7 ]; then
  agency="CHS"
elif [ ${response} -eq 8 ]; then
  agency="CST"
elif [ ${response} -eq 9 ]; then
  agency="DMVA"
elif [ ${response} -eq 10 ]; then
  agency="DNR"
elif [ ${response} -eq 11 ]; then
  agency="DOC"
elif [ ${response} -eq 12 ]; then
  agency="DOLA"
elif [ ${response} -eq 13 ]; then
  agency="DOR"
elif [ ${response} -eq 14 ]; then
  agency="DORA"
elif [ ${response} -eq 15 ]; then
  agency="DPA"
elif [ ${response} -eq 16 ]; then
  agency="GOV"
elif [ ${response} -eq 17 ]; then
  agency="HCPF"
elif [ ${response} -eq 18 ]; then
  agency="OIT"
elif [ ${response} -eq 19 ]; then
  agency="OITEDIT"
fi
} #}}}

install_package() { #{{{
if [[ ${silentinstall} = "true" ]]; then
  case ${distro} in
    Redhat | CentOS | Oracle | SLES | openSUSE | Amazon)
      echo -e "Installing Tanium client for ${distro}, version ${majversion}" >> "${logfile}"
      rpm -ivh ${installpkg} >> "${logfile}" 2>&1
    ;;
    Debian | debian | Ubuntu)
      echo -e "Installing Tanium client for ${distro}, version ${majversion}" >> "${logfile}"
      dpkg -i ${installpkg} >> "${logfile}" 2>&1
    ;;
    *)
      echo -e "${f_red}In function install_package: Unrecognized distro, exiting. ${distro}${reset}" >> "${logfile}"
      exit 1
    ;;
  esac
else
  case ${distro} in
    Redhat | CentOS | Oracle | SLES | openSUSE | Amazon)
      echo -e "Installing Tanium client for ${distro}, version ${majversion}"
      rpm -ivh ${installpkg}
    ;;
    Debian | debian | Ubuntu)
      echo -e "Installing Tanium client for ${distro}, version ${majversion}"
      dpkg -i ${installpkg}
    ;;
    *)
      echo -e "${f_red}In function install_package: Unrecognized distro, exiting. ${distro}${reset}"
      exit 1
    ;;
  esac
fi
} # }}}

configure_tanium() { #{{{
if [[ ${silentinstall} = "true" ]]; then
  echo -e "This script will now configure the required settings and start the service" >> "${logfile}"
  if [[ ${pub_exists} = "true" ]]; then
    echo -e "Installing pub file: ${taniumpub}" >> "${logfile}"
    cp ${taniumpub} /opt/Tanium/TaniumClient/
  elif [[ ${pub_exists} = "false" ]]; then
    echo -e "Tanium public key not found, exiting." >> "${logfile}"
    exit 1
  fi
  if [[ ${taniumini} = "true" ]]; then
    taniumver=$(ls ${installpkg} | cut -d '_' -f 2 | cut -d '-' -f 1)
    echo "Version=${taniumver}" > /opt/Tanium/TaniumClient/TaniumClient.ini
    echo -e "Setting Tanium parameters:" >> "${logfile}"
    echo -e "  Tanium server IP: ${serverip}" >> "${logfile}"
    echo "ServerName=${serverip}" >> /opt/Tanium/TaniumClient/TaniumClient.ini
    echo -e "  Tanium server port: ${taniumport}" >> "${logfile}"
    echo "ServerPort=${taniumport}" >> /opt/Tanium/TaniumClient/TaniumClient.ini
    echo -e "  Tanium log verbosity level: ${verbosity}" >> "${logfile}"
    echo "LogVerbosityLevel=${verbosity}" >> /opt/Tanium/TaniumClient/TaniumClient.ini
  else
    echo -e "Setting Tanium parameters:" >> "${logfile}"
    echo -e "  Tanium server IP: ${serverip}" >> "${logfile}"
    /opt/Tanium/TaniumClient/TaniumClient config set ServerNameList ${serverip}
    echo -e "  Tanium server port: ${taniumport}" >> "${logfile}"
    /opt/Tanium/TaniumClient/TaniumClient config set taniumport ${taniumport}
    echo -e "  Tanium log verbosity level: ${verbosity}" >> "${logfile}"
    /opt/Tanium/TaniumClient/TaniumClient config set LogVerbosityLevel ${verbosity}
  fi
  echo -e "Setting Agency custom tag to: ${agency}" >> "${logfile}"
  if [ -d /opt/Tanium/TaniumClient/Tools ]; then
    echo -e "~~${agency}" > /opt/Tanium/TaniumClient/Tools/CustomTags.txt
  else
    mkdir /opt/Tanium/TaniumClient/Tools
    echo -e "~~${agency}" > /opt/Tanium/TaniumClient/Tools/CustomTags.txt
  fi
else
  echo -e "\n"
  echo -e "This script will now configure the required settings and start the service"
  if [[ ${pub_exists} = "true" ]]; then
    echo -e "Installing pub file: ${f_green}${taniumpub}${reset}"
    cp ${taniumpub} /opt/Tanium/TaniumClient/
  elif [[ ${pub_exists} = "false" ]]; then
    echo -e "${f_red}In function configure_tanium: Tanium public key not found, exiting.${reset}"
    exit 1
  fi
  if [[ ${taniumini} = "true" ]]; then
    taniumver=$(ls ${installpkg} | cut -d '_' -f 2 | cut -d '-' -f 1)
    echo "Version=${taniumver}" > /opt/Tanium/TaniumClient/TaniumClient.ini
    echo -e "Setting Tanium parameters:"
    echo -e "  Tanium server IP: ${f_green}${serverip}${reset}"
    echo "ServerName=${serverip}" >> /opt/Tanium/TaniumClient/TaniumClient.ini
    echo -e "  Tanium server port: ${f_green}${taniumport}${reset}"
    echo "ServerPort=${taniumport}" >> /opt/Tanium/TaniumClient/TaniumClient.ini
    echo -e "  Tanium log verbosity level: ${f_green}${verbosity}${reset}"
    echo "LogVerbosityLevel=${verbosity}" >> /opt/Tanium/TaniumClient/TaniumClient.ini
  else
    echo -e "Setting Tanium parameters:"
    echo -e "  Tanium server IP: ${f_green}${serverip}${reset}"
    /opt/Tanium/TaniumClient/TaniumClient config set ServerNameList ${serverip}
    echo -e "  Tanium server port: ${f_green}${taniumport}${reset}"
    /opt/Tanium/TaniumClient/TaniumClient config set taniumport ${taniumport}
    echo -e "  Tanium log verbosity level: ${f_green}${verbosity}${reset}"
    /opt/Tanium/TaniumClient/TaniumClient config set LogVerbosityLevel ${verbosity}
  fi
  echo -e "Setting Agency custom tag to: ${f_green}${agency}${reset}"
  if [ -d /opt/Tanium/TaniumClient/Tools ]; then
    echo -e "~~${agency}" > /opt/Tanium/TaniumClient/Tools/CustomTags.txt
  else
    mkdir /opt/Tanium/TaniumClient/Tools
    echo -e "~~${agency}" > /opt/Tanium/TaniumClient/Tools/CustomTags.txt
  fi
fi
} #}}}

start_services() { #{{{
if [[ ${silentinstall} = "true" ]]; then
  if [[ ${installmethod} = "svc" ]]; then
    echo -e "Starting Tanium service" >> "${logfile}"
    service "${clientname}" start >> "${logfile}" 2>&1
  elif [[ ${installmethod} = "systemd" ]]; then
    echo -e "Starting Tanium service" >> "${logfile}"
    systemctl start "${clientname}" >> "${logfile}" 2>&1
  fi
else
  if [[ ${installmethod} = "svc" ]]; then
    echo -e "Starting Tanium service"
    service "${clientname}" start
  elif [[ ${installmethod} = "systemd" ]]; then
    echo -e "Starting Tanium service"
    systemctl start "${clientname}"
  fi
fi
} #}}}

final_message() { #{{{
if [[ ${silentinstall} = "true" ]]; then
  if [[ ${distro} = "Amazon" ]]; then
    echo -e "Installation Complete" >> "${logfile}"
    echo -e "Please verify that your AWS security group allows ${taniumport}/TCP and ${taniumport2}/TCP" >> "${logfile}"
    echo -e "to ${serverip}" >> "${logfile}"
    exit 0
  else
    echo -e "Installation Complete" >> "${logfile}"
    echo -e "Please verify that firewall ports ${taniumport}/TCP and ${taniumport2}/TCP" >> "${logfile}"
    echo -e "are open to ${serverip}" >> "${logfile}"
    exit 0
  fi
else
  echo -e "${f_green}Installation Complete${reset}"
  echo -e "Please verify that firewall ports ${taniumport}/TCP and ${taniumport2}/TCP"
  echo -e "are open to ${serverip}"
  exit 0
fi
} #}}}

# BEGIN PROCESSING
check_root
get_distro
get_distroversion
validate_distroversion
get_arch
validate_arch
# get_domain # UNUSED FOR NOW
select_package
validate_package
if [[ "$#" -eq 0 ]]; then
  show_banner
  prompt_agency
  install_package
  configure_tanium
  start_services
  final_message
elif [[ "$#" -eq 1 ]]; then
  get_args "$1"
  show_banner
  prompt_agency
  install_package
  configure_tanium
  start_services
  final_message
else
  echo -e "${f_red}Unrecognized command line argument, exiting${reset}"
  exit 1
fi
exit 0
