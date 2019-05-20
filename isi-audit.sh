#!/usr/bin/bash
# Purpose: Wrapper to parse through isi_audit_viewer data
# Date: 2019-04-19
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
dateregex='^[0-9]{4}-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01]) ([0-2][0-9]:[0-5][0-9])$'
efx400logdate="1450388912" # Earliest date on EFX400 Isilon - Thu Dec 17 14:48:32 MST 2015
curdate="$(date +%s)"
local_os="$(uname -o)"
# outfile="/ifs/${curdate}_log.out"
nodecount="$(ls -l /ifs/.ifsvar/audit/logs | wc -l)"
# zcat <nodelog.gz> | sed -e /s/,"/\>/g' | tr -d "\"" | tr -d "{}" | gzip > filter.gz
# }}}

# Functions {{{

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
        if [[ "${epoch_sdate}" -lt "${efx400logdate}" ]] || [[ "${epoch_sdate}" -gt "${curdate}" ]]; then
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
        if [[ "${epoch_sdate}" -lt "${efx400logdate}" ]] || [[ "${epoch_sdate}" -gt "${curdate}" ]]; then
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
        if [[ "${epoch_edate}" -gt "${curdate}" ]]; then
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
        if [[ "${epoch_edate}" -gt "${curdate}" ]]; then
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

prompt_sloc(){ # {{{ Static Menu for AD/Zone param setting - vars: user_sloc, user_zone, user_ad
valid_sloc="false"
while [[ "${valid_sloc}" = "false" ]]; do
  echo -e "\nAvailable AD domains / Access zones to search are:"
  printf "%-12s %-12s\n" "[1] CDA" "[7] CST"
  printf "%-12s %-12s\n" "[2] CDHS" "[8] DEPTS"
  printf "%-12s %-12s\n" "[3] CDLE" "[9] DOLA"
  printf "%-12s %-12s\n" "[4] CDOC" "[10] GOV"
  printf "%-12s %-12s\n" "[5] CDOT" "[11] HCPF"
  printf "%-12s %-12s\n" "[6] CDPHE" "[12] OIT"
  printf "%-12s\n" "[13] DOTTST"
#  echo -n "Which domain/Access zone are we searching: "
  read -rp "Which domain / Access Zone are we searching: " user_sloc
  case "${user_sloc}" in
  1)
    user_zone="CDA"
    user_ad="INT.AG.STATE.CO.US"
    valid_sloc="true"
  ;;
  2)
    user_zone="CDHS"
    user_ad="CDHS.STATE.CO.US"
    valid_sloc="true"
  ;;
  3)
    user_zone="CDLE"
    user_ad="CDLE.INT"
    valid_sloc="true"
  ;;
  4)
    user_zone="CDOC"
    user_ad="CDOC.CORRECTIONS.LCL"
    valid_sloc="true"
  ;;
  5)
    user_zone="CDOT"
    user_ad="DOT.STATE.CO.US"
    valid_sloc="true"
  ;;
  6)
    user_zone="CDPHE"
    user_ad="DPHE.LOCAL"
    valid_sloc="true"
  ;;
  7)
    user_zone="CST"
    user_ad="TREASURY.COLORADO.LCL"
    valid_sloc="true"
  ;;
  8)
    user_zone="DEPTS"
    user_ad="DEPTS.COLORADO.LCL"
    valid_sloc="true"
  ;;
  9)
    user_zone="DOLA"
    user_ad="DOLA.LOCAL"
    valid_sloc="true"
  ;;
  10)
    user_zone="GOV"
    user_ad="STATECAPITOL.COLORADO.LCL"
    valid_sloc="true"
  ;;
  11)
    user_zone="HCPF"
    user_ad="HCPF.STATE.CO.US"
    valid_sloc="true"
  ;;
  12)
    user_zone="OIT"
    user_ad="OIT.COLORADO.LCL"
    valid_sloc="true"
  ;;
  13)
    user_zone="DOTTST"
    user_ad="DOTTSTDOMAIN.COM"
    valid_sloc="true"
  ;;
  *)
    echo -e "Error: Invalid Access Zone / Domain entered"
  ;;
  esac
done
} # }}} End prompt_sloc

prompt_sloc2(){ #{{{ IN PROGRESS - build dynamic AD/Zone pairing for prompt
echo -e "Querying AD provider list..."
declare -a adslist=( $(isi auth ads list --no-header --no-footer | grep online | cut -d" " -f1) )
echo -e "Done, continuing.\n"
PS3="Enter Selection: "
select user_sloc in "${adslist[@]}"; do
  valid_opt="true"
  break;
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
      echo -n "What is the Windows AD user id to search: "
      read -e -r user_suser
      if [[ "${local_os}" != *inux* ]]; then
        user_sid="$(isi auth users view --zone="${user_zone}" --user="${user_ad}"\\"${user_suser}" | grep SID | cut -d: -f2)"
      else
        echo -e "--> Isilon command to lookup user SID runs here <--"
        user_sid="IsilonCommandWouldPutTheSIDHere"
      fi
      search_param="${user_sid}"
      valid_stype="true"
    ;;
    p | P)
      user_stype="Path"
      echo -e "Enter the path with the format of"
      printf "%s\n" '\ifs\<accesszone>\path\to\search'
      echo -e "Partial paths are ok, but will increase the"
      echo -e "number of matches. Wildcards are not necessary."
      echo -e "Also, remember the share we are searching"
      echo -e "will need to be translated to an Isilon path,"
      echo -e "so a partial path in your access zone should"
      echo -e "be fine."
      read -rp "What is the path to search: " user_spath
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

generate_logs(){ # {{{ For loop to get>put each nodes logs to a .gz file in /ifs - outfile is /ifs/node-<#>_log.gz
# search_range="$(( epoch_edate - epoch_sdate ))"
# if [[ "${search_range}" -gt "86400" ]]; then
#   echo -e "Notice: Search range is greater than 1 day, this may be slow"
# else
#   echo -e "Notice: Search range is less than 1 day"
# fi
if [[ "${local_os}" = *inux* ]]; then
  echo -e "-->  isi_audit_viewer loop runs here  <--"
else
  for (( count=1; count < nodecount; count++)); do
    isi_audit_viewer -t protocol -n "${count}" -s "${user_sdate}" -e "${user_edate}" \
    | grep -i "${search_param}" | sed -e 's/,"/\>/g' | tr -d "\"" | tr -d "{}" | gzip  > /ifs/node-"${count}"_log.gz
  done
fi

} # }}} End generate_logs

resolve_sid(){ #{{{ Takes a sid as argument and resolves it - vars: res_user
res_user="$(isi auth users view --zone="${user_zone}" --sid="$@" | grep -w "Name:" | cut -d" " -f2)"
} # End resolve_sid }}}

parse_log(){ # {{{ Pull out relevant parts of audit record for formatting
:
} # }}} End parse_log

create_share(){ # {{{ EXPERIMENTAL generic share creation
echo -e "Share will be created with Everyone - Full Control SMB permissions"
read -p -r -e "Share Access Zone: " user_shareaz
read -p -r -e "Share name: " user_sharename
read -p -r -e "Share description: " user_sharedescription
read -p -r -e "Share path: " user_sharepath
isi smb shares create "${user_sharename}" "${user_sharepath}" --create-path --description="${user_sharedescription}" --zone="${user_shareaz}" 
isi smb shares permission "${user_sharename}" --wellknown Everyone --permission full --zone="${user_shareaz}"
} # }}} End create share

# }}} End functions section

# Begin main tasks  {{{
prompt_stime
prompt_etime
generate_logs
prompt_sloc
prompt_stype
echo -e "\nStart is: ${user_sdate}"
echo -e "End is: ${user_edate}"
echo -e "Search size is: ${search_range}"
echo -e "Search location is: ${user_zone}"
echo -e "Search type is: ${user_stype}"
if [[ "${user_stype}" = "User" ]]; then
  echo -e "Search criteria: ${user_suser}"
  echo -e "User resolves to: ${user_sid}"
else
  echo "Search criteria: ${user_spath}"
fi
# }}}

exit 0
