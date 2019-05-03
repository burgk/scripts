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

# Begin main tasks {{{
if [[ "$#" = "0" ]]; then
  for dir in .[!.]* *; do
    if [[ -d "${dir}" ]]; then
      cd "${dir}" || exit
      size=$("du" -s | cut -f1) >/dev/null 2>&1
      echo -e "${size};${dir}" >> "${tmpfile}"
      cd .. || exit
    fi
  done
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
