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
parse_log(){ # {{{ Pull out relevant parts of audit record for formatting
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
  if ( $7 == "eventType:create" ) print $1,$6,$7,$8,$9,$10,$11,"",$13,$15 ;
  else if ( $7 == "eventType:rename" ) print $1,$6,$7,$8,$9,$10,$11,$12,"","" ;
  else print $1,$6,$7,$8,$9,$10,$11,"","","" ; }' >> "${loglist[$i]%.*}".csv
done
declare -a audres_list
audres_list=( *.csv )
echo -e "\n"
for i in "${!audres_list[@]}"; do
  echo -e "--> Formatting records from ${audres_list[$i]} <--"
  cat "${audres_list[$i]}" \
  | sed -nE 's/[[[:digit:]]{1,}: //gp' \
  | sed -nE 's/] id:([[:alnum:]]{1,}-){1,}[[:alnum:]]{1,}//gp' \
  | sed -nE 's/\\\\/\\/gp' >> node_"$((i + 1))"_AuditResult.csv
done
} # }}} End parse_log

# }}}

# Begin main tasks {{{
parse_log

# }}}

exit 0
