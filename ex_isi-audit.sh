#!/usr/bin/bash

valchar='^[0-9]+$'
isilogdate="1450015382"
curdate="$(date +%s)"
echo -n "Enter start date in the format YYYY-MM-DD HH:MM  : "
read -e -r user_sdate
if [[ "${user_sdate}" =~ ${valchar} ]]; then
  echo -e "Invalid data type, numbers expected"
fi
epoch_sdate="$(date --date="${user_sdate}" +%s)"
if [[ "${epoch_sdate}" -lt "${isilogdate}" ]]; then
  echo -e "Start date is too early"
  exit 1
fi
echo -n "Enter end date in the format YYYY-MM-DD HH:MM  : "
read -e -r user_edate
epoch_edate="$(date --date="${user_edate}" +%s)"
if [[ "${epoch_edate}" -gt "${curdate}" ]]; then
  echo -e "End date is too late"
  exit 1
fi
echo -e "Start is: ${user_sdate} - ${epoch_sdate}"
echo -e "End is: ${user_edate} - ${epoch_edate}"
if [[ "${epoch_sdate}" -gt "${epoch_edate}" ]]; then
  echo -e "Error: start before end"
  exit 1
fi
exit 0
