#!/usr/bin/env bash
# Purpose: Get fqdn of host from a list
# Date: 20191204
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
infile=/home/burgk/hostlist.txt
outfile=/home/burgk/hostfqdn.txt
# }}}

# Begin main tasks {{{
while read -r hostname; do
  if host "${hostname}" &>/dev/null; then
    fqdn=$(host "${hostname}" | awk '{ print $1 }')
    echo -e "${fqdn}" >> "${outfile}"
  else
    echo -e "${hostname}" >> "${outfile}"
  fi
done < ${infile} # }}}

exit 0
