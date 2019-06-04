#!/usr/bin/bash
# Purpose: Wrapper to parse through isi_audit_viewer data
# Date: 2019-04-19
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
trap "int_clean" 2 3
dateregex='^[0-9]{4}-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01]) ([0-2][0-9]:[0-5][0-9])$' # date format regex
zoneregex='(([[:upper:]]{1,}\.){1,}[[:upper:]]{1,})' # regex that matches the domain provider
azregex='[[:digit:]]{1,}' # search location option regex
efx400logdate="1450388912" # Earliest date on EFX400 Isilon - Thu Dec 17 14:48:32 MST 2015
ts=$(date +%s) # time stamp
local_os="$(uname -o)" # only needed when testing on linux
nodecount="$(ls -l /ifs/.ifsvar/audit/logs | wc -l)" # node count +1
iaopath="/ifs/iao-${ts}" # isi-audit output path
time_count="0"
# }}}

# Functions {{{

show_header(){ # {{{ Header
echo -e "\n"
cat <<'HEADERMSG'
**************************************************************
**     ___             ___ __     __  ____  _ ___ __        **
**    /   | __  ______/ (_) /_   / / / / /_(_) (_) /___  __ **
**   / /| |/ / / / __  / / __/  / / / / __/ / / / __/ / / / **
**  / ___ / /_/ / /_/ / / /_   / /_/ / /_/ / / / /_/ /_/ /  **
** /_/  |_\__,_/\__,_/_/\__/   \____/\__/_/_/_/\__/\__, /   **
**                                                /____/    **
**************************************************************
HEADERMSG
} # }}} End display_header

prompt_sdate(){ # {{{ Prompt and validate supplied start date - vars: user_sdate, epoch_sdate
valid_sdate="false"
echo -e "\n*************************"
echo -e "**  SEARCH TIME ENTRY  **"
echo -e "*************************"
while [ "${valid_sdate}" = "false" ]; do
  read -rep "Enter start date in the format YYYY-MM-DD HH:MM: " user_sdate
  if ! [[ ${user_sdate} =~ $dateregex ]]; then
    echo -e "ERROR: Invalid date format, need YYYY-MM-DD HH:MM"
   elif [[ $(date -j -f "%F %T" "${user_sdate}":00 +%s) ]]; then # FreeBSD date format
     epoch_sdate="$(date -j -f "%F %T" "${user_sdate}":00 +%s)" # FreeBSD date format
       if [[ "${epoch_sdate}" -lt "${efx400logdate}" ]] || [[ "${epoch_sdate}" -gt "${ts}" ]]; then
         echo -e "ERROR: Date is out of range"
       elif [[ "${time_count}" -gt "0" ]] && [[ "${epoch_sdate}" -lt "${epoch_edate}" ]]; then
         valid_sdate="true"
       elif [[ "${time_count}" -gt "0" ]] && [[ "${epoch_sdate}" -ge "${epoch_edate}" ]]; then
         echo -e "ERROR: Start time is newer than end time!"
         echo -e "If you need to adjust both, please adjust end time first."
       else
         valid_sdate="true"
       fi
#    fi
  else
    echo -e "ERROR: Invalid date entered"
  fi
done
} # }}} End prompt_sdate

prompt_edate(){ # {{{ Prompt and validate supplied end date - vars: user_edate, epoch_edate
valid_edate="false"
while [ "${valid_edate}" = "false" ]; do
  read -rep "Enter end date in the format YYYY-MM-DD HH:MM: " user_edate
  if ! [[ ${user_edate} =~ $dateregex ]]; then
    echo -e "ERROR: Invalid date format, need YYYY-MM-DD HH:MM"
  elif [[ $(date -j -f "%F %T" "${user_edate}":00 +%s) ]]; then # FreeBSD date format
    epoch_edate="$(date -j -f "%F %T" "${user_edate}":00 +%s)" # FreeBSD date format
      if [[ "${epoch_edate}" -gt "${ts}" ]]; then
        echo -e "ERROR: End date is in the future"
      elif [[ "${epoch_edate}" -lt "${epoch_sdate}" ]]; then
        echo -e "ERROR: End date is before start date"
      else
        valid_edate="true"
      fi
  fi
#  fi
done
((time_count++))
} # }}} End prompt_edate

build_sloc(){ # {{{ Build search location data structure
if ! [[ -e "${iaopath}" ]]; then
  mkdir "${iaopath}"
fi
echo -e "\n*****************************"
echo -e "**  SEARCH LOCATION ENTRY  **"
echo -e "*****************************"
echo -e "--> Building Access Zone list for cluster.. <--"
declare -a az_list=()
while read -r line; do az_list+=("$line"); done < <( isi zone zones list -a -z | cut -d" " -f1 | sort )
for i in "${!az_list[@]}"; do
  touch "${iaopath}/${az_list[$i]}"
done
echo -e "--> Getting AD providers for Access Zones.. <--"
cd "${iaopath}" || exit
for file  in *; do
  if [[ $(isi zone zones view "${file}" | grep -Eo "${zoneregex}") =~ $zoneregex ]]; then
    mv "${file}" "${file} - "$(isi zone zones view "${file}" | grep -Eo "${zoneregex}");
  fi
done
if ! [[ -e "${iaopath}"/online ]]; then
  mkdir "${iaopath}"/online
fi
echo -e "--> Finding online AD providers.. <--"
cd "${iaopath}" || exit
for file in *-*; do
  # if [[ $(isi auth ads view "${file##*,}" 2>/dev/null | grep -o online) == "online" ]]; then # more accurate, but significantly slower
  if [[ $(isi auth status | grep  "${file##* - }" | grep -o online) == "online" ]]; then
    mv "${file}" ./online/
  fi
done
} # }}} End build_sloc

prompt_sloc(){ #{{{ Dynamic AD/Zone pairing - vars: user_zone, user_ad, zone_path
declare -a agency=()
cd "${iaopath}"/online || exit
agency=( * )
valid_sloc="false"
while [ "${valid_sloc}" == "false" ]; do
  echo -e "\nSelect the Access Zone - AD Provider are we searching:\n"
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
    echo -e "ERROR: Invalid selection"
  fi
done
} # }}} End prompt_sloc

prompt_stype(){ # {{{ Prompt for search type: User or Path - vars: user_stype, user_suser, user_sid, user_spath, search_param
valid_stype="false"
while [[ "${valid_stype}" = "false" ]]; do
  echo -e "\n*************************"
  echo -e "**  SEARCH TYPE ENTRY  **"
  echo -e "*************************"
  read -rp "Will this search be for a [U]ser or [P]ath: " user_tmptype
  case "${user_tmptype}" in
    u | U)
      user_stype="User"
      valid_user="false"
      while [ "${valid_user}" == "false" ]; do
        read -rep "What is the Windows AD user id to search in ${user_ad}: " user_suser
        if [[ "${local_os}" != *inux* ]]; then
          user_sid="$(isi auth users view --zone="${user_zone}" --user="${user_ad}"\\"${user_suser}" 2>/dev/null | grep SID | awk -F" " '{print $2}')"
          if [[ "${#user_sid}" == "0" ]]; then
            echo -e "ERROR: User not found, please re-enter\n"
          else
            mkdir "${iaopath}"/users || exit
            touch "${iaopath}"/users/"${user_suser}_${user_sid}"
            valid_user="true"
          fi
        else
          echo -e "--> Isilon command to lookup user SID runs here <--"
          user_sid="IsilonCommandWouldPutTheSIDHere"
        fi
      done
      search_param="${user_sid}"
      valid_stype="true"
    ;;
    p | P)
      user_stype="Path"
      echo -e "\n"
      cat <<'PATHMESSAGE'
For a path search there are a few options. We can perform
a case insensitive search on a file, directory or path.

If you want to search on a path, please format it like:
\path\to\search
Do not include the \ifs\<agency> portion.

Remember, the less specific the search criteria are the
more likely we are to get unexpected matches, e.g. there
may be several 'New Text Document.txt' in any given agency.

PATHMESSAGE
      read -rep "What is the file, directory or path to search: " user_spath
      search_param="${user_spath//\\/\\\\\\\\}"
      valid_stype="true"
    ;;
    *)
      echo -e "ERROR: Invalid choice, please type:"
      echo -e "u | U for a user based search"
      echo -e "p | P for a directory based search"
    ;;
  esac
done
} # }}} End prompt_search

show_selections(){ # {{{ Display input and get user confirmation - vars: user_agree
user_agree="n"
echo -e "\nYou entered:\n"
echo -e "Start date/time: ${user_sdate}"
echo -e "End date/time: ${user_edate}"
echo -e "Search location: ${user_zone} - ${user_ad}"
if [[ "${user_stype}" == "User" ]]; then
  echo -e "Search type: ${user_stype} - ${user_suser}"
else
  echo -e "Search type: ${user_stype} - ${search_param}"
fi
echo -n "\nDo your entries look correct [y|n]: "
read -r user_agree
} # }}} End show_selections

generate_logs(){ # {{{ For loop to get>put each nodes logs to a .gz file in ${iaopath}/node_<#>_log.gz
if [[ "${local_os}" = *inux* ]]; then
  echo -e "-->  isi_audit_viewer loop runs here  <--"
else
  echo -e "\n**********************************"
  echo -e "**  LOG GENERATION - FILTERING  **"
  echo -e "**********************************"
  echo -e "Generating logs, please wait.."
  for (( count=1; count < nodecount; count++)); do
    echo -e "--> Collecting logs from node ${count}.. <--"
    isi_audit_viewer -t protocol -n "${count}" -s "${user_sdate}" -e "${user_edate}" \
    | grep "${zone_path}" \
    | grep -i "${search_param}" \
    | sed -e 's/,"/\>/g' | tr -d "\"" | tr -d "{}" \
    | gzip \
    > "${iaopath}"/node_"${count}"_log.gz
  done
fi
} # }}} End generate_logs

resolve_sid(){ #{{{ Takes a sid as argument and resolves it - vars: res_user
res_user="$(isi auth users view --zone="${user_zone}" --sid="$@" | grep -w "Name:" | cut -d" " -f2)"
} # End resolve_sid }}}

parse_log(){ # {{{ Pull out relevant parts of audit record for formatting
echo -e "\n********************************"
echo -e "**  LOG PARSING - FORMATTING  **"
echo -e "********************************"

} # }}} End parse_log

int_clean(){ # {{{ Clean up on Ctrl-C
echo -e "\n*****************************************"
echo -e "**  NOTICE: Interrupt signal detected  **"
echo -e "*****************************************"
echo -e "--> Cleaning up <--"
if [[ -e "${iaopath}" ]]; then
  rm -rf "${iaopath}"
fi
echo -e "--> Done <--"
exit 1
} # End cleanup

# }}} End functions section

comp_clean(){ # {{{ Clean up after successful run
echo -e "\n***************************"
echo -e "**  PROCESSING COMPLETE  **"
echo -e "***************************"
echo -e "Log files have been left in ${iaopath}"
echo -e "Please remove them if they are no longer needed"
rm -rf "${iaopath}"/online
rm -rf "${iaopath}"/users
rm -rf "${iaopath}"*-*
} # }}} End comp_cleanup

# Begin main tasks  {{{
show_header
prompt_sdate
prompt_edate
build_sloc
prompt_sloc
prompt_stype
show_selections
while [ "${user_agree}" == "n" ]; do
  echo -e "\nWhich entry would you like to change?"
  echo -e "[1] Start date/time"
  echo -e "[2] End date/time"
  echo -e "[3] Search location"
  echo -e "[4] Search type"
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
    prompt_sloc
    show_selections
    ;;
    4)
    prompt_stype
    show_selections
    ;;
  esac
done
echo -e "User entries have been confirmed, continuing.."
generate_logs
parse_log
comp_clean

# }}}

exit 0
