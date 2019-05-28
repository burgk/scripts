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
  # if [[ $(isi auth ads view "${file##*,}" 2>/dev/null | grep -o online) == "online" ]]; then
  if [[ $(isi auth status | grep  "${file##* - }" | grep -o online) == "online" ]]; then
    mv "${file}" ./online/
  fi
done
declare -a agency=()
cd "${iaopath}"/online || exit
agency=( * )
echo -e "\nSelect the online AD Provider - Access Zone are we searching:"
echo -e "Enter 99 to quit instead\n"
# select file in "${agency[@]}"; do
#   if [[ "${file}" == "99" ]]; then
#     echo -e "99 selected, cleaning up.."
#     rm -rf /ifs/"${iaopath}"
#     exit 0
#   else
arrsize="${#agency[@]}"
for ((count=0; count < arrsize; count++)); do
  echo -e "$((count + 1)) ${agency[$count]}"
#    user_zone="${file% - *}"
#    user_ad="${file##* - }"
#    break
#  fi
done
read -rep "Enter number of selection: " user_tmp
if [[ "${user_tmp}" =~ [[:digit:]]{1,} ]] && [[ "${user_tmp}" -le "${arrsize}" ]]; then
  echo -e "${user_tmp}"
  user_sloc=$((user_tmp - 1))
  user_param="${agency[$user_sloc]}"
  echo -e "${user_param}"
  user_zone="${user_param% - *}"
  user_ad="${user_param##* - }"
  echo -e "User zone: ${user_zone}"
  echo -e "User ADS: ${user_ad}"
elif [[ "${user_tmp}" -eq "99" ]]; then
  echo -e "Quit option detected, cleaning up.."
  rm -rf "${iaopath}"
  echo -e "Exiting."
else
  echo -e "Invalid selection: ${user_tmp}"
fi
# }}}

exit 0
