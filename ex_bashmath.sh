#!/usr/bin/bash

# echo -n "Enter year (YYYY): "
# read -r user_syear
# yearmod=$(( "${user_syear}" % 4 ))
# if (( "${user_syear}" / 4 )); then
# if [[ "${yearmod}" -ne "0" ]]; then
#   echo -e "${user_syear} doesn't appear to be a leap year"
# else
#   echo -e "${user_syear} appears to be a leap year"
# fi

valid="false"
while [ "${valid}" = "false" ]; do
  echo -n "Enter start year [YYYY]: "
  read -e -r user_syear
  if [[ "${user_syear}" -lt "2015" ]] || [[ "${user_syear}" -gt "2019" ]]; then
    echo -e "Year out of range"
  else
    valid="true"
  fi
done
echo "${user_syear}"
exit 0
