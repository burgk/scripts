#!/usr/bin/env bash
# Purpose: 
# Date:
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
# set -x # Enable debug
ts=$(date +%s)
mkdir /ifs/iao-"${ts}"
iaopath="/ifs/iao-${ts}" # isi-audit output path
PS3="Enter selection: "

# }}}

# Function definitions {{{

# }}}

# Begin main tasks {{{
echo -e "Building Access Zone list for cluster.."
declare -a az_list=()
while read -r line; do az_list+=("$line"); done < <( isi zone zones list -a -z | cut -d" " -f1 | sort )
for i in "${!az_list[@]}"; do
  touch "${iaopath}/${az_list[$i]}"
done
echo -e "Getting AD providers for Access Zones.."
cd "${iaopath}" || exit
for file  in *; do
  if [[ $(isi zone zones view "${file}" | grep -Eo '(([[:upper:]]{1,}\.){1,}[[:upper:]]{1,})') =~ (([[:upper:]]{1,}\.){1,}[[:upper:]]{1,}) ]]; then
    mv "${file}" "${file} - "$(isi zone zones view "${file}" | grep -Eo '(([[:upper:]]{1,}\.){1,}[[:upper:]]{1,})');
  fi
done
echo -e "Finding online AD providers, please wait.."
mkdir "${iaopath}"/online
cd "${iaopath}" || exit
for file in *-*; do
  # if [[ $(isi auth ads view "${file##*,}" 2>/dev/null | grep -o online) == "online" ]]; then # more accurate, but much slower
  if [[ $(isi auth status | grep  "${file##* - }" | grep -o online) == "online" ]]; then
    mv "${file}" ./online/
  fi
done
declare -a agency=()
cd "${iaopath}"/online || exit
agency=( * )
valid_sloc="false"
while [ "${valid_sloc}" == "false" ]; do
  echo -e "\nSelect the Access Zone - AD Provider are we searching:"
  arrsize="${#agency[@]}"
  for ((count=0; count < arrsize; count++)); do
    echo -e "$((count + 1))) ${agency[$count]}"
  done
  read -rep "Enter number of selection: " user_tmp
  if [[ "${user_tmp}" =~ [[:digit:]]{1,} ]] && [[ "${user_tmp}" -le "${arrsize}" ]]; then
    user_sloc=$((user_tmp - 1))
    user_param="${agency[$user_sloc]}"
    user_zone="${user_param% - *}"
    user_ad="${user_param##* - }"
    first_path="$(isi zone zones view --zone="${user_zone}" | grep Path | awk -F" " '{print $2}')"
    valid_sloc="true"
  else
    echo -e "Invalid selection"
  fi
done
# }}}

exit 0
