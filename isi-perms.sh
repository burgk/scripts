#!/usr/bin/env bash

declare -a sharelist=()

while read -r line; do sharelist+=("$line"); done < <( isi smb shares list --zone=CDOT -a -z | awk -F'/' '{ print $1 }' | sed 's/ *$//' )

for share in "${!sharelist[@]}"; do
  echo -e "\nChecking: ${sharelist[$share]}"
  isi smb shares view "${sharelist[$share]}" --zone=CDOT | grep CDOT_Admins 2>&1 > /dev/null
  if [[ $? == 0 ]]; then
    echo -e "${sharelist[$share]} has CDOT_Admins checking for run-as-root.."
    isi smb shares view "${sharelist[$share]}" --zone=CDOT | grep CDOT_Admins | grep True 2>&1 > /dev/null
    if [[ $? == 0 ]]; then
      echo -e "${sharelist[$share]} has CDOT_Admins with run-as-root, skipping.."
    else
      echo -e "${sharelist[$share]} has CDOT_Admins without run-as-root, fixing.."
      echo -e "--running perms modify cmd here--"
      isi smb shares permission modify "${sharelist[$share]}" --group CDOT_Admins --run-as-root --zone=CDOT
    fi
  else
    echo -e "${sharelist[$share]} does NOT have CDOT_Admins, adding.."
    echo -e "--running perms add cmd here--"
     isi smb shares permission create "${sharelist[$share]}" --group CDOT_Admins --run-as-root --zone=CDOT
  fi
done
