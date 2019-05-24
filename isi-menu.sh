#!/usr/bin/env bash
# Purpose: 
# Date:
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
# set -x # Enable debug

# }}}

# Function definitions {{{

# }}}

# Begin main tasks {{{
echo -e "Generate Access Zone info for cluster.."
declare -a az_list=()
while read -r line; do az_list+=("$line"); done < <( isi zone zones list -a -z | cut -d" " -f1 | sort )
declare -a ads_list=()
echo -e "whole az_list array: ${az_list[@]}"
echo -e "size of array: ${#az_list[@]}"
echo -e "element 0: ${az_list[0]}"
echo -e "element 1: ${az_list[1]}"
echo -e "element 2: ${az_list[2]}"
echo -e "Generating AD provider list for discovered Access Zone.."
for agency in "${az_list[@]}"; do
  adspresent=$( isi zone zones view "${agency}" | grep -Eo '(([[:upper:]]{1,}\.){1,}[[:upper:]]{1,})' )
  if [[ "${adspresent}" =~ (([[:upper:]]{1,}\.){1,}[[:upper:]]{1,}) ]]; then
    while read -r line; do ads_list+=("$line"); done < <( isi zone zones view "${agency}" | grep -Eo '(([[:upper:]]{1,}\.){1,}[[:upper:]]{1,})' )
  else
    echo -e "No AD provider for ${agency}"
  fi
done
echo -e "whole array: ${ads_list[@]}"
echo -e "size of array: ${#ads_list[@]}"
echo -e "element 0: ${ads_list[0]}"
echo -e "element 1: ${ads_list[1]}"
echo -e "element 2: ${ads_list[2]}"
echo -e "element 3: ${ads_list[3]}"
# }}}

exit 0
