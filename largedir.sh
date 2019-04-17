#!/usr/bin/env bash
# Purpose: Find the largest directory in a list
# Date: 20190417
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
mapfile -s1 -t dirlist < <(find . -maxdepth 1 -type d | cut -b 3-)
tmpfile="/tmp/$(date +%s)-largedir.temp"
# }}}

# Begin main tasks {{{
for dir in "${dirlist[@]}"; do
  cd "${dir}" || exit
  size=$("du" -s | cut -f1) >/dev/null 2>&1
  echo -e "${size};${dir}" >> "${tmpfile}"
  cd .. || exit
done
sort -rn "${tmpfile}" | column -s";" -t
rm "${tmpfile}"
# }}}

exit 0
