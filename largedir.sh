#!/usr/bin/env bash
# Purpose: Find the largest directory in a list
# Date: 20190417
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
mapfile -s1 -t dirlist < <(find . -maxdepth 1 -type d | cut -b 3-)
stamp="$(date +%s)"
tmpfile="/tmp/${stamp}-largedir.sh.tmp"
outfile="/tmp/${stamp}-largedir.sh.out"
pager="$(command -v less)"
termsize="$(tput lines)"
# }}}

# Begin main tasks {{{

# if [[ "$#" = "0" ]]; then
#   mapfile -s1 -t dirlist < <(find . -maxdepth 1 -type d | cut -b 3-)
# else
#   userpath="${1}"
#   cd "${userpath}" || exit
#   mapfile -s1 -t dirlist < <(find . -maxdepth 1 -type d | cut -b 3-)
# fi
  
for dir in "${dirlist[@]}"; do
  cd "${dir}" || exit
  size=$("du" -s | cut -f1) >/dev/null 2>&1
  echo -e "${size};${dir}" >> "${tmpfile}"
  cd .. || exit
done

echo -e "Size in KB;Directory" > "${outfile}"
echo -e "---m--g---;---------" >> "${outfile}"
sort -rn "${tmpfile}" >> "${outfile}"

if [[ "${#dirlist[@]}" -ge  "${termsize}" ]]; then
  column -s";" -t < "${outfile}" | "${pager}"
else
  column -s";" -t < "${outfile}"
fi

rm "${tmpfile}"
rm "${outfile}"
# }}}

exit 0
