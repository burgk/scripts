#!/usr/bin/env bash
# Purpose: Find the largest directories in the current dir
# Date: 2019-04-21
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
stamp="$(date +%s)"
tmpfile="/tmp/${stamp}-largedir.sh.tmp"
outfile="/tmp/${stamp}-largedir.sh.out"
pager="$(command -v less)"
termsize="$(tput lines)"

# }}}

# Functions {{{
get_sizes(){ # {{{
for dir in .[!.]* *; do
  if [[ -d "${dir}" ]]; then
    cd "${dir}" 2>/dev/null || return 
    size=$("du" -s 2>/dev/null | cut -f1)
    echo -e "${size};${dir}" >> "${tmpfile}"
    cd .. || exit
  else
    :
  fi
done
} # }}} End get_sizes

# }}}

# Begin main tasks {{{
if [[ "$#" = "0" ]]; then
  if (( EUID != 0 )); then
    echo -e "WARNING: Not running as EUID 0, some directories may not be accessible"
    read -rp "Continue anyway? " response
    case "${response}" in
    y | Y)
      :
    ;;
    n | N)
      echo -e "Ok, exiting"
      exit 1
    ;;
    *)
      echo -e "Invalid response, exiting"
      exit 1
    ;;
    esac
  fi
  get_sizes
else
  echo -e "No arguments supported, this must be run from the location"
  echo -e "you want the list from.  Use of sudo or root may be"
  echo -e "required for some directories. Exiting now."
  exit 1
fi

echo -e "Size  in  KB;Directory" > "${outfile}"
echo -e "---m--g--t--;---------" >> "${outfile}"
sort -rn "${tmpfile}" >> "${outfile}"
rm "${tmpfile}"

listsize=$(wc -l "${outfile}" | cut -d" " -f 1)
if [[ "${listsize}" -ge  "${termsize}" ]]; then
  column -s";" -t < "${outfile}" | "${pager}"
else
  column -s";" -t < "${outfile}"
fi

rm "${outfile}"
# }}}

exit 0
