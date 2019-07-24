#!/usr/bin/env bash
# Purpose: Wrapper for virt-install to prompt for values
# Date: 07/24/2019
# Kevin Burg - kevin.burg@state.co.us

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

# Misc variable definitions {{{

# }}}

# Begin main tasks {{{
cat <<HEADERMSG
************************
**  NEW KVM BASED VM  **
************************
HEADERMSG

read -rep "VM Name: " vm_name
read -rep "Memory: " vm_mem
read -rep "Disk Path: " vm_disk_path
read -rep "DisK Size: " vm_disk_size
read -rep "VCPUs: " vm_cpus
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

