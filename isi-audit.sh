#!/usr/bin/env bash
# Purpose: Wrapper to parse through isi_audit_viewer data
# Date: 2019-04-19
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
trap "int_clean" 2 3
dateregex='^[0-9]{4}-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01]) ([0-2][0-9]:[0-5][0-9])$' # date format regex
zoneregex='(([[:upper:]]{1,}\.){1,}[[:upper:]]{1,})' # regex that matches the domain provider
azregex='[[:digit:]]{1,}' # search location option regex
sidregex='S-[[:digit:]]-([[:digit:]]{1,}-){1,}[[:digit:]]{1,}' # updated to match well known sids
efx400logdate="1450388912" # Earliest date on EFX400 Isilon - Thu Dec 17 14:48:32 MST 2015
ts=$(date +%s) # time stamp
hts=$(date +%Y-%m-%d) # human friendly time stamp
nodecount="$(ls -l /ifs/.ifsvar/audit/logs | wc -l)" # node count +1
realnodecount=$((nodecount - 1))
iaopath="/ifs/iao-${ts}" # isi-audit output path
time_count="0"

# Terminal color definitions {{{
# Define 8 bit foreground colors
f_red="\e[31m"
f_green="\e[32m"
f_yellow="\e[33m"
# Non color settings
reset="\e[0m"
# }}}

# }}} End misc vars

# Functions {{{

show_header(){ # {{{ Header
echo -e "\n ${f_green}"
cat <<'HEADERMSG'
****************************************************************
**      ___             ___ __     __  ____  _ ___ __         **
**     /   | __  ______/ (_) /_   / / / / /_(_) (_) /___  __  **
**    / /| |/ / / / __  / / __/  / / / / __/ / / / __/ / / /  **
**   / ___ / /_/ / /_/ / / /_   / /_/ / /_/ / / / /_/ /_/ /   **
**  /_/  |_\__,_/\__,_/_/\__/   \____/\__/_/_/_/\__/\__, /    **
**                                                 /____/     **
**                                                            **
****************************************************************

This utility functions as a wrapper around the isi_audit_viewer
command on Isilon.  It will prompt for the search criteria and
then collect the logs from each node for the times indicated.
Once the logs have been collected, it will parse and format 
them for importing into Excel or Google Sheets as a '>'
(greater than symbol) delimited file.
Some of the steps it performs may take a significant amount of
time as we wait for the Isilon to pull out all the log files.
If your search duration is more than a few days, you may want
to stop and re-run this script from inside a screen session so
you can detach and let it run in the background.

HEADERMSG
echo -e "${reset}"
} # }}} End display_header

prompt_sdate(){ # {{{ Prompt and validate supplied start date - vars: user_sdate, epoch_sdate
valid_sdate="false"
echo -e "\n${f_green}*************************"
echo -e "**  SEARCH TIME ENTRY  **"
echo -e "*************************${reset}"
echo -e "NOTE: Earliest allowed date is 2015-12-17 14:49"
echo -e "NOTE: Minimal testing has been done with dates prior to 2017.\n"
while [ "${valid_sdate}" = "false" ]; do
  echo -ne "Enter ${f_green}start${reset} date in the format YYYY-MM-DD HH:MM : "
  echo -ne "${f_green}"
  read -re user_sdate
  echo -ne "${reset}"
  if ! [[ ${user_sdate} =~ $dateregex ]]; then
    echo -e "\n${f_red}-->  -------------------------------------------------  <--"
    echo -e "-->  ERROR: Invalid date format, need YYYY-MM-DD HH:MM  <--"
    echo -e "-->  -------------------------------------------------  <--\n${reset}"
  elif [[ $(date -j -f "%F %T" "${user_sdate}":00 +%s) ]]; then # FreeBSD date format
    epoch_sdate="$(date -j -f "%F %T" "${user_sdate}":00 +%s)" # FreeBSD date format
    if [[ "${epoch_sdate}" -lt "${efx400logdate}" ]] || [[ "${epoch_sdate}" -gt "${ts}" ]]; then
      echo -e "\n${f_red}-->  ---------------------------  <--"
      echo -e "-->  ERROR: Date is out of range  <--"
      echo -e "-->  ---------------------------  <--\n${reset}"
    elif [[ "${time_count}" -gt "0" ]] && [[ "${epoch_sdate}" -lt "${epoch_edate}" ]]; then
      valid_sdate="true"
    elif [[ "${time_count}" -gt "0" ]] && [[ "${epoch_sdate}" -ge "${epoch_edate}" ]]; then
      echo -e "\n${f_red}-->  ---------------------------------------------------------  <--"
      echo -e "-->  ERROR: Start time is newer than end time!                  <--"
      echo -e "-->  If you need to adjust both, please adjust end time first.  <--"
      echo -e "-->  ---------------------------------------------------------  <--\n${reset}"
    else
      valid_sdate="true"
    fi
  fi
done
} # }}} End prompt_sdate

prompt_edate(){ # {{{ Prompt and validate supplied end date - vars: user_edate, epoch_edate
valid_edate="false"
while [ "${valid_edate}" = "false" ]; do
  echo -ne "Enter  ${f_yellow}end${reset}  date in the format YYYY-MM-DD HH:MM : "
  echo -ne "${f_yellow}"
  read -re  user_edate
  echo -ne "${reset}"
  if ! [[ ${user_edate} =~ $dateregex ]]; then
    echo -e "\n${f_red}-->  -------------------------------------------------  <--"
    echo -e "-->  ERROR: Invalid date format, need YYYY-MM-DD HH:MM  <--"
    echo -e "-->  -------------------------------------------------  <--\n${reset}"
  elif [[ $(date -j -f "%F %T" "${user_edate}":00 +%s) ]]; then # FreeBSD date format
    epoch_edate="$(date -j -f "%F %T" "${user_edate}":00 +%s)" # FreeBSD date format
    if [[ "${epoch_edate}" -gt "${ts}" ]]; then
      echo -e "\n${f_red}-->  --------------------------------  <--"
      echo -e "-->  ERROR: End date is in the future  <--"
      echo -e "-->  --------------------------------  <--\n${reset}"
    elif [[ "${epoch_edate}" -lt "${epoch_sdate}" ]]; then
      echo -e "\n${f_red}-->  ------------------------------------  <--"
      echo -e "-->  ERROR: End date is before start date  <--"
      echo -e "-->  ------------------------------------  <--\n${reset}"
    else
      valid_edate="true"
    fi
  fi
done
((time_count++))
} # }}} End prompt_edate

build_sloc(){ # {{{ Build search location data structure
if ! [[ -e "${iaopath}" ]]; then
  mkdir "${iaopath}" 2>/dev/null || error_exit "ERROR at line $LINENO: Unable to mkdir ${iaopath}"
fi
echo -e "\n${f_green}*****************************"
echo -e "**  SEARCH LOCATION ENTRY  **"
echo -e "*****************************${reset}"
echo -e "${f_yellow}-->  Building Access Zone list for cluster..${reset}"
declare -a az_list=()
while read -r line; do az_list+=("$line"); done < <( isi zone zones list -a -z | cut -d" " -f1 | sort )
cd "${iaopath}" 2>/dev/null || error_exit "ERROR at line $LINENO: Unable to cd to ${iaopath}"
for i in "${!az_list[@]}"; do
  touch "${az_list[$i]}"
done

echo -e "${f_yellow}-->  Getting AD providers for Access Zones..${reset}"
for file  in *; do
  if [[ $(isi zone zones view "${file}" | grep -Eo "${zoneregex}") =~ $zoneregex ]]; then
    mv "${file}" "${file} - "$(isi zone zones view "${file}" | grep -Eo "${zoneregex}");
  fi
done

if ! [[ -e "${iaopath}"/online ]]; then
  mkdir "${iaopath}"/online 2>/dev/null || error_exit "ERROR at line $LINENO: Unable to mkdir ${iaopath}/online"
fi
echo -e "${f_yellow}-->  Finding online AD providers..${reset}"
for file in *-*; do
  # if [[ $(isi auth ads view "${file##*,}" 2>/dev/null | grep -o online) == "online" ]]; then # NOTE: more accurate, but *significantly* slower
  if [[ $(isi auth status | grep  "${file##* - }" | grep -o online) == "online" ]]; then
    mv "${file}" online/
  fi
done

for file in *; do
  if [[ -f "${file}" ]]; then
    rm -f "${file}"
  fi
done
} # }}} End build_sloc

prompt_sloc(){ #{{{ Dynamic AD/Zone pairing - vars: user_zone, user_ad, zone_path
declare -a agency=()
cd "${iaopath}"/online 2>/dev/null || error_exit "ERROR at line $LINENO: Unable to cd to ${iaopath}/online"
agency=( * )
valid_sloc="false"
while [ "${valid_sloc}" == "false" ]; do
  echo -e "\nSelect the Access Zone - AD Provider we are searching:\n"
  arrsize="${#agency[@]}"
  for ((count=0; count < arrsize; count++)); do
    echo -e "[$((count + 1))] ${agency[$count]}"
  done
  echo -e "\n"
  read -rep "Enter number of selection: " user_tmp
  if [[ "${user_tmp}" =~ $azregex ]] && [[ "${user_tmp}" -le "${arrsize}" ]]; then
    user_sloc=$((user_tmp - 1))
    user_param="${agency[$user_sloc]}"
    user_zone="${user_param% - *}"
    user_ad="${user_param##* - }"
    tmp_path="$(isi zone zones view --zone="${user_zone}" | grep Path | awk -F" " '{print $2}' | tr '/' '\')"
    zone_path="${tmp_path//\\/\\\\\\\\}"
    valid_sloc="true"
  else
    echo -e "\n${f_red}-->  ------------------------  <--"
    echo -e "-->  ERROR: Invalid selection  <--"
    echo -e "-->  ------------------------  <--\n${reset}"
  fi
done
} # }}} End prompt_sloc

prompt_stype(){ # {{{ Prompt for search type: User, Path or Delete - vars: user_stype, user_suser, user_sid, user_spath, search_param, parse_arg
valid_stype="false"
while [[ "${valid_stype}" = "false" ]]; do
  echo -e "\n${f_green}*************************"
  echo -e "**  SEARCH TYPE ENTRY  **"
  echo -e "*************************${reset}"
  read -rep "Will this search be for a [U]ser, [P]ath or [D]eletion: " user_tmptype
  case "${user_tmptype}" in
    u | U)
      user_stype="User"
      valid_user="false"
      while [ "${valid_user}" == "false" ]; do
        read -rep "What is the Windows AD user id to search for in ${user_ad}: " user_suser
        user_sid="$(isi auth users view --zone="${user_zone}" --user="${user_ad}"\\"${user_suser}" 2>/dev/null | grep SID | head -n 1 | awk -F" " '{print $2}')"
        if [[ "${#user_sid}" == "0" ]]; then
          echo -e "${f_red}"
          printf "%55s\n" "-->  ----------------------------------------------  <--"
          printf "%-50s %5s\n" "-->  ERROR: User: ${user_suser}  " "<--"
          printf "%-50s %5s\n" "-->  Not found in: ${user_ad}  " "<--"
          printf "%-50s %5s\n" "-->  Please re-enter  " "<--"
          printf "%55s\n" "-->  ----------------------------------------------  <--"
          echo -e "${reset}\n"
        else
          if [[ -e "${iaopath}"/user ]]; then # should only exist if editing
            rm -rf "${iaopath}"/user/* 2>/dev/null # silently remove previous entry
            touch "${iaopath}"/user/"${user_ad%%.*}\\${user_suser}_${user_sid}"
            valid_user="true"
          else
            mkdir "${iaopath}/user" 2>/dev/null || error_exit "ERROR at line $LINENO: Unable to mkdir ${iaopath}/user"
            touch "${iaopath}/user/${user_ad%%.*}\\${user_suser}_${user_sid}"
            valid_user="true"
          fi
        fi
      done
      search_param="${user_sid}"
      parse_arg="all"
      valid_stype="true"
    ;;
    p | P)
      user_stype="Path"
      echo -e "\n"
      cat <<'PATHMESSAGE'
For a path search there are a couple options. We will perform
a case insensitive search for a file or directory path.
NOTE: The search operates on the Isilon path which may differ from
the SMB share path.

If you want to search for a directory path, please format it like:
\path\to\search
Do not include the \ifs\<agency> portion.

Remember, the less specific the search criteria are the
more likely we are to get unexpected matches, e.g. there
may be several 'New Text Document.txt' in any given path.
Alternatively, too specific may cause us to miss if we have
any errors in the path.

PATHMESSAGE
      read -rep "What is the file or directory path to search for: " user_spath
      search_param="${user_spath//\\/\\\\\\\\}"
      parse_arg="all"
      valid_stype="true"
    ;;
    d |D)
      user_stype="Delete"
      echo -e "\n"
      cat <<'DELMESSAGE'
For a deletion search, we'll need the name of the file or
directory as if it were a [P]ath search, but the script
will format the output to show *only* delete event types.

DELMESSAGE
      read -rep "What is the deleted file or directory we are searching for: " user_spath
      search_param="${user_spath//\\/\\\\\\\\}"
      parse_arg="delete"
      valid_stype="true"
    ;;
    *)
      echo -e "\n${f_red}-->  ---------------------------------------  <--"
      echo -e "-->  ERROR: Invalid choice, please type:      <--"
      echo -e "-->  u | U for a user based search            <--"
      echo -e "-->  p | P for a directory path based search  <--"
      echo -e "-->  d | D for a delete event type search     <--"
      echo -e "-->  ---------------------------------------  <--\n${reset}"
    ;;
  esac
done
} # }}} End prompt_search

show_selections(){ # {{{ Display input and get user confirmation - vars: user_agree
user_agree="n"
echo -e "\n${f_green}***********************"
echo -e "**  USER SELECTIONS  **"
echo -e "***********************${reset}"
echo -e "You entered:\n"
echo -e "Start date/time:  ${f_green}${user_sdate}${reset}"
echo -e "End date/time:    ${f_green}${user_edate}${reset}"
echo -e "Search location:  ${f_green}${user_zone} - ${user_ad}${reset}"
if [[ "${user_stype}" == "User" ]]; then
  echo -e "Search type:      ${f_green}${user_stype} - ${user_suser}${reset}"
else 
  echo -ne "Search type:      ${f_green}"; echo -n "${user_stype} - ${user_spath}"; echo -e "${reset}"
fi
echo -e "\n"
read -rep "Do your entries look correct [y|n]: " user_agree
} # }}} End show_selections

collect_logs(){ # {{{ For loop to get>put each nodes logs to a .gz file in ${iaopath}/node_<#>_log.gz
echo -e "\n${f_green}**********************************"
echo -e "**  LOG COLLECTION - FILTERING  **"
echo -e "**********************************${reset}"
cat <<'LOGMSG'
This is generally the slowest part of this
operation as we are waiting for the Isilon
to retrieve all the records and may take a
significant amount of time depending on how
large the search range is. For large time
range searches, you might consider breaking
up the work into multiple searches and then
merging the results in Excel or Google Sheets.

LOGMSG
cd "${iaopath}" 2>/dev/null || error_exit "ERROR at line $LINENO: Unable to cd to ${iaopath}"
for (( count=1; count < nodecount; count++)); do
  echo -e "${f_yellow}-->  Collecting logs from node ${count} of ${realnodecount}..${reset}"
    isi_audit_viewer -t protocol -n "${count}" -s "${user_sdate}" -e "${user_edate}" \
    | grep "${zone_path}" \
    | grep -i "${search_param}" \
    | sed -e 's/,"/\>/g' | tr -d "\"" | tr -d "{}" \
    | gzip \
    > "${iaopath}"/node_"${count}"_log.gz
  rec_count_1=$(zcat node_"${count}"_log.gz | wc -l | awk -F" " '{ print $1 }')
  if [[ "${rec_count_1}" == "0" ]]; then
    echo -e "${f_yellow}--->  Log contained ${reset}${f_red}${rec_count_1}${reset}${f_yellow} relevant records, removing..${reset}"
    rm node_"${count}"_log.gz
  else
    echo -e "${f_yellow}--->  Log contains ${reset}${f_green}${rec_count_1}${reset}${f_yellow} filtered records${reset}"
  fi
done
} # }}} End collect_logs

resolve_sid(){ #{{{ Takes a sid as argument and resolves it - vars: res_user
if [[ -e "${iaopath}"/user ]]; then
  cd "${iaopath}"/user 2>/dev/null || error_exit "ERROR at line $LINENO: Unable to cd to ${iaopath}/user"
else
  mkdir "${iaopath}"/user 2>/dev/null || error_exit "ERROR at line $LINENO: Unable to mkdir ${iaopath}/user"
  cd "${iaopath}"/user 2>/dev/null || error_exit "ERROR at line $LINENO: Unable to cd to ${iaopath}/user"
fi
res_user="$(isi auth users view --zone="${user_zone}" --sid="$1" 2>/dev/null | grep -w "Name:" | head -n1 | awk -F" " '{print $2}')"
if [[ "${res_user}" ]]; then
  touch "${res_user}"_"$1"
else
  res_user="$1"
  touch "${res_user}"_"$1"
fi
} # End resolve_sid }}}

parse_log(){ # {{{ Filter for relevant parts of audit record and format as csv for Excel/Google Sheets
echo -e "\n${f_green}********************************"
echo -e "**  LOG PARSING - FORMATTING  **"
echo -e "********************************${reset}"
cd "${iaopath}" 2>/dev/null || error_exit "ERROR at line $LINENO: Unable to cd to ${iaopath}"
declare -a loglist
loglist=( *.gz )
if [[ "${1}" == "all" ]]; then
  for i in "${!loglist[@]}"; do
    echo -e "${f_yellow}-->  Pulling relevant fields from ${loglist[$i]%.*}..${reset}"
    zcat "${loglist[$i]}" | awk -F">" 'BEGIN{OFS=">"} {
    if ( $7 == "eventType:create" ) print $1,$7,$8,$9,$15,"NA for Event",$11,$13 ;
    else if ( $7 == "eventType:rename" ) print $1,$7,"NA for Event",$8,$10,$11,$9,$12 ;
    else print $1,$7,"NA for Event",$8,$10,"NA for Event",$9,$11 ; }' >> "${loglist[$i]%.*}".tmp1
    rec_count_2=$(wc -l "${loglist[$i]%.*}".tmp1 | awk -F" " '{ print $1 }')
    echo -e "${f_yellow}--->  Log contains ${reset}${f_green}${rec_count_2}${reset}${f_yellow} records${reset}"
  done
elif [[ "${1}" == "delete" ]]; then
  for i in "${!loglist[@]}"; do
    echo -e "${f_yellow}-->  Pulling delete events from ${loglist[$i]%.*}..${reset}"
    zcat "${loglist[$i]}" | awk -F">" 'BEGIN{OFS=">"} {
    if ( $7 == "eventType:delete" ) print $1,$7,$8,$10,$9,$11 ; }' \
    >> "${loglist[$i]%.*}".tmp1
    rec_count_2=$(wc -l "${loglist[$i]%.*}".tmp1 | awk -F" " '{ print $1 }')
    if [[ "${rec_count_2}" == "0" ]]; then
      echo -e "${f_yellow}-->   No delete events found, removing..${reset}"
      rm -f "${loglist[$i]%.*}".tmp1
    else
      echo -e "${f_yellow}--->  Log contains ${reset}${f_green}${rec_count_2}${reset}${f_yellow} delete records${reset}"
    fi
  done
fi

if (ls *.tmp1 &>/dev/null); then
  cd "${iaopath}" 2>/dev/null || error_exit "ERROR at line $LINENO: Unable to cd to ${iaopath}"
  declare -a audres_list
  audres_list=( *.tmp1 )
  for i in "${!audres_list[@]}"; do
    echo -e "${f_yellow}-->  Formatting fields from ${audres_list[$i]%.*}..${reset}"
    cat "${audres_list[$i]}" \
    | sed -nE 's/[[[:digit:]]{1,}: //gp' \
    | sed -nE 's/] id:([[:alnum:]]{1,}-){1,}[[:alnum:]]{1,}//gp' \
    | sed -nE 's/>[[:alpha:]]{1,}:/>/gp' \
    | sed -nE 's/\\\\/\\/gp' \
    >> "${audres_list[$i]%.*}".tmp2
    rec_count_3="$(wc -l "${audres_list[$i]%.*}.tmp2" | awk -F" " '{ print $1 }')"
    echo -e "${f_yellow}--->  Log contains ${reset}${f_green}${rec_count_3}${reset}${f_yellow} records${reset}"
  done
  rm -f *.tmp1
else
  nd_clean
fi

cd "${iaopath}" 2>/dev/null || error_exit "ERROR at line $LINENO: Unable to cd to ${iaopath}"
if [[ "${user_stype}" == "Path" ]] || [[ "${user_stype}" == "Delete" ]]; then
  echo -e "${f_yellow}-->  Building SID list..${reset}"
  for file in *.tmp2; do
    grep -Eo "${sidregex}" "${file}" >> ./sidlist.tmp
  done
  sort sidlist.tmp | uniq > sidlist
  rm sidlist.tmp
  sidcount=$(wc -l sidlist | awk -F" " '{ print $1 }')
  count=1
  while read -r SID; do
    echo -e "${f_yellow}-->  Resolving SID ${count} of ${sidcount}..${reset}"
    resolve_sid "${SID}"
    (( count++ ))
  done < sidlist
fi

cd "${iaopath}"/user 2>/dev/null || error_exit "ERROR at line $LINENO: Unable to cd to ${iaopath}/user"
echo -e "${f_yellow}-->  Updating records with UserID..${reset}"
for log in ../*.tmp2; do
  for user in *; do
    sid="${user#*_}"
    name="${user%_*}"
    sed -nE "s/${sid}/${name/\\/ - }/gp" "${log}" >> "${log%.*}".tmp3
  done
done
rm -f ./*.tmp2

cd "${iaopath}" 2>/dev/null || error_exit "ERROR at line $LINENO: Unable to cd to ${iaopath}"
if [[ "${1}" == "all" ]]; then
  header="Time Stamp>Event Type>Create Result>Is Directory>Filename>New Filename>Client IP>User Name"
elif [[ "${1}" == "delete" ]]; then
  header="Time Stamp>Event Type>Is Directory>Filename>Client IP>User Name"
fi
declare -a headerlist
headerlist=( *.tmp3 )
for i in "${!headerlist[@]}"; do
  echo "${header}" > "${headerlist[$i]%.*}".csv
  cat "${headerlist[$i]}" >> "${headerlist[$i]%.*}".csv
  rec_count_3=$(wc -l "${headerlist[$i]%.*}".csv | awk -F" " '{ print $1 }')
  echo -e "${f_yellow}-->  Log contains ${reset}${f_green}${rec_count_3}${reset}${f_yellow} formatted records including new header${reset}"
done
rm -f "${iaopath}"/*.tmp3
rm -f header

for file in *.csv; do
  mv "${file}" "${file/log/result}"
done
} # }}} End parse_log

int_clean(){ # {{{ Clean up on Ctrl-C
echo -e "\n\n${f_green}*****************************************"
echo -e "**  NOTICE: Interrupt signal detected  **"
echo -e "*****************************************${reset}"
echo -e "${f_red}-->  User aborted - Cleaning up"
if [[ -e "${iaopath}" ]]; then
  rm -rf "${iaopath}"
fi
echo -e "-->  Done - Goodbye\n${reset}"
exit 1
} # }}} End int_clean

nd_clean(){ # {{{ Clean up after no data run
echo -e "\n\n${f_green}*******************************"
echo -e "**  NOTICE: No data matched  **"
echo -e "*******************************${reset}"
echo -e "Unfortunately, no data matched the search"
echo -e "criteria provided. If this was a path search"
echo -e "there may have been path elements missing."
echo -e "Or in a 'Delete' type search there may have"
echo -e "not been any delete events for the path or time"
echo -e "specified."
echo -e "${f_yellow}-->  Cleaning up"
if [[ -e "${iaopath}" ]]; then
  rm -rf "${iaopath}"
fi
echo -e "-->  Done - Goodbye\n${reset}"
exit 0
} # }}} End nd_clean

comp_clean(){ # {{{ Clean up after successful run
echo -e "\n${f_green}***************************"
echo -e "**  PROCESSING COMPLETE  **"
echo -e "***************************${reset}"
cd "${iaopath}" 2>/dev/null || error_exit "ERROR at line $LINENO: Unable to cd to ${iaopath}"
rm -rf online 2>/dev/null
rm -rf user 2>/dev/null
rm -rf *-* 2>/dev/null
rm -rf *.gz 2>/dev/null
rm -rf *.tmp* 2>/dev/null
rm -rf sidlist 2>/dev/null
tar cfz "${hts}"_AuditResults.tar.gz *.csv 2>/dev/null
rm -rf *.csv 2>/dev/null
echo -e "The Audit result file(s) have been saved as:"
echo -e "\n${f_green}${iaopath}/${hts}_AuditResults.tar.gz\n${reset}"
echo -e "which is a compressed tar archive."
echo -e "You will need to copy it to your local system."
echo -e "Once there, it needs to be uncompressed and"
echo -e "unarchived. Then, it can be imported as a"
echo -e "'>' delimited file in Excel or Google Sheets."
echo -e "\n${f_yellow}NOTE: Do not forget to remove the directory ${iaopath}"
echo -e "after you have collected the results file.\n${reset}"
exit 0
} # }}} End comp_cleanup

error_exit(){ # {{{ Generic error handling
echo "${f_red}${1:-"Unknown Error"}${reset}" 1>&2
exit 1
} # }}} End error_exit

# }}} End functions section

# Begin main tasks  {{{
show_header
user_cont=""
until [[ "${user_cont}" == [yY] || "${user_cont}" == [nN] ]]; do
  read -rep "Do you want to continue? [y|n]: " user_cont
done
if [[ "${user_cont}" == [yY] ]]; then 
  prompt_sdate
  prompt_edate
  build_sloc
  prompt_sloc
  prompt_stype
  show_selections
  while [ "${user_agree}" == "n" ]; do
    echo -e "\n${f_green}**********************"
    echo -e "**  EDIT SELECTION  **"
    echo -e "**********************${reset}"
    echo -e "Which entry would you like to change?\n"
    echo -e "[1] Start date/time"
    echo -e "[2] End date/time"
    echo -e "[3] Search location"
    echo -e "[4] Search type\n"
    read -rep "Enter selection: " user_change
    case "${user_change}" in
      1)
      prompt_sdate
      show_selections
      ;;
      2)
      prompt_edate
      show_selections
      ;;
      3)
      echo -e "\n${f_yellow}-->  ----------------------------------------------------------  <--"
      echo -e "-->  WARNING: Location changing, search type must be re-entered  <--"
      echo -e "-->  ----------------------------------------------------------  <--${reset}"
      sleep 1
      prompt_sloc
      prompt_stype
      show_selections
      ;;
      4)
      prompt_stype
      show_selections
      ;;
    esac
  done
  echo -e "\n${f_green}-->  User entries have been confirmed, continuing..${reset}"
  collect_logs
  if [[ $(ls "${iaopath}"/*.gz 2>/dev/null) ]]; then
    parse_log "${parse_arg}"
    comp_clean
  else
    nd_clean
  fi
else
  echo -e "Ok, exiting - Goodbye"
  exit 0
fi
# }}} End main tasks
