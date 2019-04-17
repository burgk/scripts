#!/usr/bin/env bash
# Purpose: Find the largest directory in a list
# Date: 20190417
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
mapfile -s1 -t dirlist < <(find . -maxdepth 1 -type d | cut -b 3-)
tmpfile="/tmp/$(date +%s)-largedir.tmp"
outfile="/tmp/$(date +%s)-largedir.out"
# }}}

# Begin main tasks {{{
for dir in "${dirlist[@]}"; do
  cd "${dir}" || exit
  size=$("du" -s | cut -f1) >/dev/null 2>&1
  echo -e "${size};${dir}" >> "${tmpfile}"
  cd .. || exit
done
echo -e "Size in KB;Directory" > "${outfile}"
echo -e "----------;---------" >> "${outfile}"
sort -rn "${tmpfile}" | cat "${tmpfile}" >> "${outfile}"
column -s";" -t < "${outfile}"
rm "${tmpfile}"
rm "${outfile}"
# }}}

exit 0
