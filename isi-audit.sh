#!/usr/bin/bash
# Purpose: Wrapper to parse through isi_audit_viewer data
# Date: 2019-04-19
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
dateregex='^[0-9]{4}-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01]) ([0-2][0-9]:[0-5][0-9])$'
efx400logdate="1450388912" # Earliest date on EFX400 Isilon - Thu Dec 17 14:48:32 MST 2015
ts=$(date +%s) # time stamp
local_os="$(uname -o)"
nodecount="$(ls -l /ifs/.ifsvar/audit/logs | wc -l)"
mkdir /ifs/iao-"${ts}"
iaopath="/ifs/iao-${ts}" # isi-audit output path
# zcat <nodelog.gz> | sed -e /s/,"/\>/g' | tr -d "\"" | tr -d "{}" | gzip > filter.gz
# }}}

# Functions {{{

display_header(){ # {{{ Initial header
cat <<'HEADERMSG'

HEADERMSG
# }}} End display_header

prompt_stime(){ # {{{ Prompt and validate supplied start date - vars: user_sdate, epoch_sdate
valid_sdate="false"
while [ "${valid_sdate}" = "false" ]; do
  echo -n "Enter start date in the format YYYY-MM-DD HH:MM  "
  read -e -r user_sdate
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
  echo -n "Enter end date in the format YYYY-MM-DD HH:MM  "
  read -e -r user_edate
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
          echo -e "Error: Date is out of range"
        elif [[ "${epoch_edate}" -lt "${epoch_sdate}" ]]; then
          echo -e "Error: Start date is before end date"
        else
          valid_edate="true"
        fi
    fi
  fi
done
} # }}} End prompt_etime

prompt_sloc(){ #{{{ Dynamic AD/Zone pairing for prompt - vars: user_zone, user_ad, zone_path
echo -e "Building Access Zone list for cluster.."
declare -a az_list=()
while read -r line; do az_list+=("$line"); done < <( isi zone zones list -a -z | cut -d" " -f1 | sort )
for i in "${!az_list[@]}"; do
  touch "${iaopath}/${az_list[$i]}"
done
echo -e "Getting AD providers for Access Zones.."
cd "${iaopath}" || exit
for file  in *; do
  if [[ $(isi zone zones view "${file}" | grep -Eo '(([[:upper:]]{1,}\.){1,}[[:upper:]]{1,})') =~ (([[:upper:]]{1,}\.){1,}[[:upper:]]{1,}) ]]; then
    mv "${file}" "${file} - "$(isi zone zones view "${file}" | grep -Eo '(([[:upper:]]{1,}\.){1,}[[:upper:]]{1,})');
  fi
done
echo -e "Finding online AD providers, please wait.."
mkdir "${iaopath}"/online
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
  if [[ "${user_tmp}" =~ [[:digit:]]{1,} ]] && [[ "${user_tmp}" -le "${arrsize}" ]]; then
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
} # }}} End prompt_sloc2

prompt_stype(){ # {{{ Prompt for search type: User or Path - vars: user_stype, user_sid, user_spath, search_param
valid_stype="false"
while [[ "${valid_stype}" = "false" ]]; do
  echo -e "\n"
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
      cat <<'PATHMESSAGE'
For a path search, there are a few options.
We can perform a case insensitive
search on a file, directory or path.

If you want to search on a path
please enter it with the format of:
\path\to\search
Do not include the \ifs\<agency> portion.

Remember, the less specific your item is
the more likely we are to get unexpected matches
e.g. there may be a lot of files named 
'New Text Document.txt' in any given agency.

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
:
} # }}} End parse_log

create_share(){ # {{{ WARNING: EXPERIMENTAL - generic share creation
echo -e "Share will be created with Everyone - Full Control SMB permissions"
read -rep "Share Access Zone: " user_shareaz
read -rep "Share name: " user_sharename
read -rep "Share description: " user_sharedescription
read -rep "Share path: " user_sharepath
isi smb shares create "${user_sharename}" "${user_sharepath}" --create-path --description="${user_sharedescription}" --zone="${user_shareaz}" 
isi smb shares permission "${user_sharename}" --wellknown Everyone --permission full --zone="${user_shareaz}"
} # }}} End create share

# }}} End functions section

# Begin main tasks  {{{
prompt_stime
prompt_etime
prompt_sloc
prompt_stype
generate_logs
echo -e "\nStart is: ${user_sdate}"
echo -e "End is: ${user_edate}"
echo -e "Search type is: ${user_stype}"
echo -e "Search location is: ${user_zone}"
if [[ "${user_stype}" = "User" ]]; then
  echo -e "Search criteria: ${user_suser}"
  echo -e "User resolves to: ${search_param}"
else
  echo "Search criteria: ${search_param}"
fi
# }}}

exit 0
