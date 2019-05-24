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
echo -e "Generate Access Zone list for cluster.."
declare -a az_list=()
while read -r line; do az_list+=("$line"); done < <( isi zone zones list -a -z | cut -d" " -f1 | sort )
for i in "${!az_list[@]}"; do
  touch "${iaopath}/${az_list[$i]}"
done
echo -e "Get AD providers for Access Zones.."
cd "${iaopath}" || exit
for file  in *; do
  if [[ $(isi zone zones view "${file}" | grep -Eo '(([[:upper:]]{1,}\.){1,}[[:upper:]]{1,})') =~ (([[:upper:]]{1,}\.){1,}[[:upper:]]{1,}) ]]; then
    mv "${file}" "${file}",$(isi zone zones view "${file}" | grep -Eo '(([[:upper:]]{1,}\.){1,}[[:upper:]]{1,})');
  fi
done
echo -e "Find online AD providers, please wait.."
mkdir "${iaopath}"/online
cd "${iaopath}" || exit
for file in *,*; do
  # if [[ $(isi auth ads view "${file##*,}" 2>/dev/null | grep -o online) == "online" ]]; then
  if [[ $(isi auth status | grep  "${file##*,}" | grep -o online) == "online" ]]; then
    mv "${file}" ./online/
  fi
done
declare -a agency=()
cd "${iaopath}"/online || exit
agency=( * )
echo -e "Select the online AD provider Access Zone are we searching:"
echo -e "Enter 99 to quit instead"
select file in "${agency[@]%,*}"; do
  if [[ "${file}" == "99" ]]; then
    echo -e "99 selected, cleaning up.."
    rm -rf /ifs/"${iaopath}"
    exit 0
  else
    echo "${file}"
    break
  fi
done
# }}}

exit 0
