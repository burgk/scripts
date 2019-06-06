#!/usr/bin/env bash
# Purpose: 
# Date:
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
# set -x # Enable debug
# ts=$(date +%s)
# iaopath="/ifs/iao-${ts}"
# testpath="/ifs/iao-1559664432"
linpath="/home/burgk/Audit/parsetest"
# }}}

# Function definitions {{{
parse_log(){ # {{{ Filter for relevant parts of audit record and format as csv for Excel
echo -e "\n********************************"
echo -e "**  LOG PARSING - FORMATTING  **"
echo -e "********************************"
declare -a loglist
cd "${linpath}" || exit
echo -e "--> Removing empty logs <--\n"
for file in *.gz; do
  if [[ $(ls -l "${file}" | awk -F" " '{ print $5 }') == "20" ]]; then
    rm "${file}"
  fi
done
loglist=( *.gz )
for i in "${!loglist[@]}"; do
  echo -e "--> Parsing logs from ${loglist[$i]} <--"
  zcat "${loglist[$i]}" | awk -F">" 'BEGIN{OFS=">"} {
  if ( $7 == "eventType:create" ) print $1,$7,$8,$9,$15,"NA for Event",$11,$13 ;
  else if ( $7 == "eventType:rename" ) print $1,$7,"NA for Event",$8,$10,$11,$9,$12 ;
  else print $1,$7,"NA for Event",$8,$10,"NA for Event",$9,$11 ; }' >> "${loglist[$i]%.*}".tmp
done
declare -a audres_list
audres_list=( *.tmp )
echo -e "\n"
for i in "${!audres_list[@]}"; do
  echo "Time Stamp>Event Type>Create Result>Is Directory>Filename>New Filename>Client IP>User Name" > "${audres_list[$i]%.*}".csv
done
for i in "${!audres_list[@]}"; do
  echo -e "--> Formatting records from ${audres_list[$i]} <--"
  cat "${audres_list[$i]}" \
  | sed -nE 's/[[[:digit:]]{1,}: //gp' \
  | sed -nE 's/] id:([[:alnum:]]{1,}-){1,}[[:alnum:]]{1,}//gp' \
  | sed -nE 's/>[[:alpha:]]{1,}:/>/gp' \
  | sed -nE 's/\\\\/\\/gp' \
  >> "${audres_list[$i]%.*}".csv
done
for file in *.csv; do
  mv "${file}" "${file/log/result}"
done
echo -e "\n--> Removing tmp files <---"
rm -rf ./*.tmp
} # }}} End parse_log

# }}}

# Begin main tasks {{{
parse_log

# }}}

exit 0
