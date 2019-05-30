#!/usr/bin/bash
# Purpose: Wrapper to parse through isi_audit_viewer data
# Date: 2019-04-19
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
dateregex='^[0-9]{4}-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01]) ([0-2][0-9]:[0-5][0-9])$' # date format regex
zoneregex='(([[:upper:]]{1,}\.){1,}[[:upper:]]{1,})' # regex that matches the domain provider
azregex='[[:digit:]]{1,}' # search location option regex
efx400logdate="1450388912" # Earliest date on EFX400 Isilon - Thu Dec 17 14:48:32 MST 2015
ts=$(date +%s) # time stamp
local_os="$(uname -o)" # only needed when testing on linux
nodecount="$(ls -l /ifs/.ifsvar/audit/logs | wc -l)" # node count +1
iaopath="/ifs/iao-${ts}" # isi-audit output path
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

prompt_stime(){ # {{{ Prompt and validate supplied start date - vars: user_sdate, epoch_sdate
valid_sdate="false"
while [ "${valid_sdate}" = "false" ]; do
  echo -e "\n"
  read -rep "Enter start date in the format YYYY-MM-DD HH:MM: " user_sdate
  if ! [[ ${user_sdate} =~ $dateregex ]]; then
    echo -e "Invalid date format, need YYYY-MM-DD HH:MM"
  elif [[ "${local_os}" = *inux* ]]; then
    if [[ $(date --date="${user_sdate}" +%s 2>/dev/null) ]]; then # Linux date format
      epoch_sdate="$(date --date="${user_sdate}" +%s)" # Linux date format
        if [[ "${epoch_sdate}" -lt "${efx400logdate}" ]] || [[ "${epoch_sdate}" -gt "${ts}" ]]; then
          echo -e "Error: Date is out of range"
        else
          valid_sdate="true"
        fi
    else
      echo -e "Error: Invalid date"
    fi
  elif [[ "${local_os}" != *inux* ]]; then
    if [[ $(date -j -f "%F %T" "${user_sdate}":00 +%s) ]]; then # FreeBSD date format
      epoch_sdate="$(date -j -f "%F %T" "${user_sdate}":00 +%s)" # FreeBSD date format
        if [[ "${epoch_sdate}" -lt "${efx400logdate}" ]] || [[ "${epoch_sdate}" -gt "${ts}" ]]; then
          echo -e "Error: Date is out of range"
        else
          valid_sdate="true"
        fi
    fi
  else
    echo -e "Invalid date entered"
  fi
done
} # }}} End prompt_stime

prompt_etime(){ # {{{ Prompt and validate supplied end date - vars: user_edate, epoch_edate
valid_edate="false"
while [ "${valid_edate}" = "false" ]; do
  read -rep "Enter end date in the format YYYY-MM-DD HH:MM: " user_edate
  if ! [[ ${user_edate} =~ $dateregex ]]; then
    echo -e "Invalid date format, need YYYY-MM-DD HH:MM"
  elif [[ "${local_os}" = *inux* ]]; then
    if [[ $(date --date="${user_edate}" +%s) ]]; then # Linux date format
      epoch_edate="$(date --date="${user_edate}" +%s)" # Linux date format
        if [[ "${epoch_edate}" -gt "${ts}" ]]; then
          echo -e "Error: Date is out of range"
        elif [[ "${epoch_edate}" -lt "${epoch_sdate}" ]]; then
          echo -e "Error: Start date is before end date"
        else
          valid_edate="true"
        fi
    fi
  elif [[ "${local_os}" != *inux* ]]; then
    if [[ $(date -j -f "%F %T" "${user_edate}":00 +%s) ]]; then # FreeBSD date format
      epoch_edate="$(date -j -f "%F %T" "${user_edate}":00 +%s)" # FreeBSD date format
        if [[ "${epoch_edate}" -gt "${ts}" ]]; then
          echo -e "Error: End date is in the future"
        elif [[ "${epoch_edate}" -lt "${epoch_sdate}" ]]; then
          echo -e "Error: End date is before start date"
        else
          valid_edate="true"
        fi
    fi
  fi
done
} # }}} End prompt_etime

prompt_sloc(){ #{{{ Dynamic AD/Zone pairing - vars: user_zone, user_ad, zone_path
if ! [[ -e "${iaopath}" ]]; then
  mkdir "${iaopath}"
fi
echo -e "\n"
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
echo -e "--> Finding online AD providers, please wait.. <--"
cd "${iaopath}" || exit
for file in *-*; do
  # if [[ $(isi auth ads view "${file##*,}" 2>/dev/null | grep -o online) == "online" ]]; then # more accurate, but significantly slower
  if [[ $(isi auth status | grep  "${file##* - }" | grep -o online) == "online" ]]; then
    mv "${file}" ./online/
  fi
done
declare -a agency=()
cd "${iaopath}"/online || exit
agency=( * )
valid_sloc="false"
while [ "${valid_sloc}" == "false" ]; do
  echo -e "\nSelect the Access Zone - AD Provider are we searching:"
  arrsize="${#agency[@]}"
  for ((count=0; count < arrsize; count++)); do
    echo -e "[$((count + 1))] ${agency[$count]}"
  done
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
    echo -e "Invalid selection"
  fi
done
} # }}} End prompt_sloc

prompt_stype(){ # {{{ Prompt for search type: User or Path - vars: user_stype, user_sid, user_spath, search_param
valid_stype="false"
while [[ "${valid_stype}" = "false" ]]; do
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
            echo -e "User not found, please re-enter\n"
          else
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
      echo -e "Error: Invalid choice, please type:"
      echo -e "u | U for a user based search"
      echo -e "p | P for a directory based search"
    ;;
  esac
done
} # }}} End prompt_search

generate_logs(){ # {{{ For loop to get>put each nodes logs to a .gz file in ${iaopath}/node-<#>_log.gz
if [[ "${local_os}" = *inux* ]]; then
  echo -e "-->  isi_audit_viewer loop runs here  <--"
else
  echo -e "Generating logs, please wait.."
  for (( count=1; count < nodecount; count++)); do
    isi_audit_viewer -t protocol -n "${count}" -s "${user_sdate}" -e "${user_edate}" \
    | grep "${zone_path}" \
    | grep -i "${search_param}" \
    | sed -e 's/,"/\>/g' | tr -d "\"" | tr -d "{}" \
    | gzip \
    > "${iaopath}"/node-"${count}"_log.gz
  done
fi

} # }}} End generate_logs

resolve_sid(){ #{{{ Takes a sid as argument and resolves it - vars: res_user
res_user="$(isi auth users view --zone="${user_zone}" --sid="$@" | grep -w "Name:" | cut -d" " -f2)"
} # End resolve_sid }}}

parse_log(){ # {{{ Pull out relevant parts of audit record for formatting
echo -e "Parsing of logs happens here.."
} # }}} End parse_log

# }}} End functions section

# Begin main tasks  {{{
show_header
user_confirm="false"
while [ "${user_confirm}" == false ]; do
  prompt_stime
  prompt_etime
  prompt_sloc
  prompt_stype
  echo -e "\nStart date/time is: ${user_sdate}"
  echo -e "End date/time is: ${user_edate}"
  echo -e "Search type is: ${user_stype}"
  echo -e "Search location is: ${user_zone}"
  if [[ "${user_stype}" = "User" ]]; then
    echo -e "Search criteria: ${user_suser}"
  else
    echo "Search criteria: ${search_param}"
  fi
  read -rep "Do these search criteria look correct [y|n]? " user_confirm_response
  case "${user_confirm_response}" in
    y | Y)
    echo -e "Ok, continuing.."
    generate_logs
    parse_log
    user_confirm="true"
    ;;
    n | N)
    echo -e "\nOk, which item needs changed?"
    echo -e "[1] Start date/time"
    echo -e "[2] End date/time"
    echo -e "[3] Search location"
    echo -e "[4] Search type"
    read -rep "Enter selection: " redo_function
    case "${redo_function}" in
      1)
      prompt_stime
      continue
      ;;
      2)
      prompt_etime
      continue
      ;;
      3)
      prompt_sloc
      continue
      ;;
      4)
      prompt_stype
      continue
      ;;
      *)
      echo -e "Error: Invalid response selected"
      ;;
    esac
    ;;
    *)
    echo -e " Error: Invalid response selected"
    ;;
  esac
done
echo -e "Complete"
# }}}

exit 0
