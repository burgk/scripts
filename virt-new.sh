#!/usr/bin/env bash
# Purpose: Wrapper for virt-install to prompt for values
# Date: 07/24/2019
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
trap "int_exit" 2 3
vm_name_regex="^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])(\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]{0,61}[a-zA-Z0-9]))*$"
vm_mem_regex="^[[:digit:]]{1,}$"
vm_cpu_regex="^[[:digit:]]{1,2}$"
# Terminal color defintions {{{
# Define 8 bit foreground colors
f_black="\e[1;30m"
f_red="\e[1;31m"
f_green="\e[1;32m"
f_yellow="\e[1;33m"
f_blue="\e[1;34m"
f_magenta="\e[1;35m"
f_cyan="\e[1;36m"
f_white="\e[1;37m"

# Set 8 bit background colors
b_black="\e[1;40m"
b_red="\e[1;41m"
b_green="\e[1;42m"
b_yellow="\e[1;43m"
b_blue="\e[1;44m"
b_magenta="\e[1;45m"
b_cyan="\e[1;46m"
b_white="\e[1;47m"
 
# Non color settings
reset="\e[0m"
# }}}

# }}} End functions

# Functions {{{

int_exit() { # {{{ Exit on Ctrl-c
echo -e "\n\n${f_red}**************************"
echo -e "**  INTERRUPT DETECTED  **"
echo -e "**************************${reset}"
echo -e "User interrupted! Exiting.\n\n"
exit 1
} # }}} End int_exit

vm_name() { # {{{ Prompt/read vm name - vars: vm_name
valid_hostname="false"
while [[ "${valid_hostname}" == "false" ]]; do
  echo -ne "Enter new VM name: "
  echo -ne "${f_cyan}"
  read -re vm_name
  echo -ne "${reset}"
  if [[ "${vm_name}" =~ $vm_name_regex ]]; then
    valid_hostname="true"
  else
    echo -e "${f_red}-->  Error: Invalid hostname, try again..${reset}"
  fi
done
} # }}} End vm_name

vm_mem() { # {{{ Prompt for memory size - vars: vm_mem
valid_vm_mem="false"
sysmem=$(free -m | grep ^Mem | awk '{print $2}')
while [[ "${valid_vm_mem}" == "false" ]]; do
  echo -ne "Enter size of memory for new vm in MiB: "
  echo -ne "${f_cyan}"
  read -re vm_mem
  echo -ne "${reset}"
  if ! [[ "${vm_mem}" =~ $vm_mem_regex ]] ; then
    echo -e "${f_red}-->  Invalid entry, try again..${reset}"
  elif [[ "${vm_mem}" < "${sysmem}" ]]; then
    valid_vm_mem="true"
  else
    echo -e "${f_red}-->  Value too large, try again..${reset}"
  fi
done
} # }}} End vm_mem

vm_diskparam() { # {{{ Prompt for disk path - vars: vm_diskpath
vm_diskpath="false"
vm_disksize="false"
while [[ "${vm_diskpath}" == "false" ]]; do
  echo -ne "Enter path for new vm disk image: "
  echo -ne "${f_cyan}"
  read -re vm_diskpath
  echo -ne "${reset}"
  vm_diskpath="true"
done
while [[ "${vm_disksize}" == "false" ]]; do
  echo -ne "Enter size for new disk: "
  echo -ne "${f_cyan}"
  read -re vm_disksize
  echo -ne "${reset}"
  vm_disksize="true"
done
} # }}} End vm_diskpath

vm_cpu() { # {{{ Prompt for number of vcpus - vars: vm_cpu
set -x
vm_cpu="false"
while [[ "${vm_cpu}" == "false" ]]; do
  echo -ne "Enter number of virtual cpus: "
  echo -ne "${f_cyan}"
  read -re vm_cpu
  echo -ne "${reset}"
  if [[ "${vm_cpu}" =~ $vm_cpu_regex ]]; then
    vm_cpu="true"
  else
    echo -e "${f_red}-->  Error: Invalid cpu count, try again..${reset}"
  fi
done
} # }}} End vm_vcpus

# }}} End functions

# Begin main tasks {{{
cat <<HEADERMSG
************************
**  NEW KVM BASED VM  **
************************
HEADERMSG

vm_name
vm_mem
vm_diskparam
vm_cpu
read -rep "OS Type: " vm_type
read -rep "OS Variant: " vm_variant
read -rep "Network type: " vm_network
read -rep "Graphics: " vm_graphics
read -rep "Location: " vm_source

if [[ $( command -v  virt-install ) ]]; then
  virt-install \
  --name "${vm_name}" \
  --memory "${vm_mem}" \
  --disk "${vm_disk_path},${vm_disk_size}" \
  --vcpus "${vm_cpus}" \
  --os-type "${vm_type}" \
  --os-variant "${vm_variant}" \
  --network "${vm_network}" \
  --graphics "${vm_graphics}" \
  --location "${vm_source}" \
  --console pty,target_type=serial \
  --extra-args 'console=ttyS0,115200n8 serial'
else
  echo -e "${f_red}ERROR: virt-install not found! Exiting.${reset}"
  exit 1
fi
# }}}
