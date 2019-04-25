#!/usr/bin/bash

dateregex='^[0-9]{4}-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01]) ([0-2][0-9]:[0-5][0-9])$'
isilogdate="1450015382"
curdate="$(date +%s)"

valid_sdate="false"
while [ "${valid_sdate}" = "false" ]; do
  echo -n "Enter start date in the format YYYY-MM-DD HH:MM  "
  read -e -r user_sdate
  if ! [[ ${user_sdate} =~ $dateregex ]]; then
    echo -e "Invalid date format, need YYYY-MM-DD HH:MM"
  elif [[ $(date --date="${user_sdate}" +%s) ]]; then
    epoch_sdate="$(date --date="${user_sdate}" +%s)"
    if [[ "${epoch_sdate}" -lt "${isilogdate}" ]] || [[ "${epoch_sdate}" -gt "${curdate}" ]]; then
      echo -e "Error: Date is out of range"
    else
      valid_sdate="true"
    fi
  else
    echo -e "Invalid date entered"
  fi
done

valid_edate="false"
while [ "${valid_edate}" = "false" ]; do
  echo -n "Enter end date in the format YYYY-MM-DD HH:MM  "
  read -e -r user_edate
  if ! [[ ${user_edate} =~ $dateregex ]]; then
    echo -e "Invalid date format, need YYYY-MM-DD HH:MM"
  elif [[ $(date --date="${user_edate}" +%s) ]]; then
    epoch_edate="$(date --date="${user_edate}" +%s)"
    if [[ "${epoch_edate}" -gt "${curdate}" ]]; then
      echo -e "Error: Date is out of range"
    elif [[ "${epoch_edate}" -lt "${epoch_sdate}" ]]; then
      echo -e "Error: Start date is before end date"
    else
      valid_edate="true"
    fi
  else
    echo -e "Invalid date entered"
  fi
done

echo -e "Start is: ${user_sdate} - ${epoch_sdate}"
echo -e "End is: ${user_edate} - ${epoch_edate}"

exit 0
