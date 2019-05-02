#!/usr/bin/env bash
# Purpose: For loop example
# Date: 2019-05-21
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
stamp="$(date +%s)"
tmpfile="/tmp/${stamp}-largedir.sh.tmp"
outfile="/tmp/${stamp}-largedir.sh.out"
# pager="$(command -v less)"
# termsize="$(tput lines)"

# }}}

# Begin main tasks {{{
for dir in *; do
  cd "${dir}" || exit
  size=$("du" -s | cut -f1) >/dev/null 2>&1
  echo -e "${size};${dir}" >> "${tmpfile}"
  cd .. || exit
done

echo -e "Size  in  KB;Directory" > "${outfile}"
echo -e "---m--g--t--;---------" >> "${outfile}"
sort -rn "${tmpfile}" >> "${outfile}"

# if [[ "${#dirlist[@]}" -ge  "${termsize}" ]]; then
#   column -s";" -t < "${outfile}" | "${pager}"
# else
#   column -s";" -t < "${outfile}"
# fi

rm "${tmpfile}"
rm "${outfile}"
# }}}

exit 0
