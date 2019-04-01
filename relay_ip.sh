#!/usr/bin/env bash
# Purpose: Check status of hosts listed in file
# Date: 20170421
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
infile=/home/burgk/ip-list.txt
# }}}

# Begin main tasks {{{
while read -r ipaddr; do
  if host "${ipaddr}" &>/dev/null; then
  tmpname=$(host "${ipaddr}" | awk -F' ' '{ print $5 }')
    if ping -c 1 "${ipaddr}" &> /dev/null; then
      pingstatus="Online"
    else
      pingstatus="Offline"
    fi
  echo -e "${ipaddr},${tmpname},${pingstatus}"
  else
    if ping -c 1 "${ipaddr}" &>/dev/null; then
      pingstatus="Online"
    else
      pingstatus="Offline"
    fi
  echo -e "${ipaddr},${pingstatus}"
  fi
done < ${infile} # }}}

exit 0
