#!/usr/bin/env bash

admgrp="cdhs_admins"
zone="CDHSHIPAA"
declare -a sharelist=()

while read -r line; do sharelist+=("$line"); done < <( isi smb shares list --zone="${zone}" -a -z | awk -F'/' '{ print $1 }' | sed 's/ *$//' )

for share in "${!sharelist[@]}"; do
  echo -e "\nChecking: ${sharelist[$share]}"
  isi smb shares view "${sharelist[$share]}" --zone="${zone}" | grep "${admgrp}" 2>&1 > /dev/null
  if [[ $? == 0 ]]; then
    echo -e "${sharelist[$share]} has "${admgrp}" checking for run-as-root.."
    isi smb shares view "${sharelist[$share]}" --zone="${zone}" | grep "${admgrp}" | grep True 2>&1 > /dev/null
    if [[ $? == 0 ]]; then
      echo -e "${sharelist[$share]} has "${admgrp}" with run-as-root, skipping.."
    else
      echo -e "${sharelist[$share]} has "${admgrp}" without run-as-root, fixing.."
      echo -e "--running perms modify cmd here--"
      isi smb shares permission modify "${sharelist[$share]}" --group "${admgrp}" --run-as-root --zone="${zone}"
    fi
  else
    echo -e "${sharelist[$share]} does NOT have "${admgrp}", adding.."
    echo -e "--running perms add cmd here--"
     isi smb shares permission create "${sharelist[$share]}" --group "${admgrp}" --run-as-root --zone="${zone}"
  fi
done
