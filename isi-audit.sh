#!/usr/bin/bash
# Purpose: Wrapper to parse through isi_audit_viewer data
# Date: 2019-04-19
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
dateregex='^[0-9]{4}-(0[1-9]|1[012])\-(0[1-9]|[12][0-9]|3[01]) ([0-2][0-9]:[0-5][0-9])$'
efisilogdate="1450015382" # Earliest date on EFX400 Isilon
curdate="$(date +%s)"
local_os="$(uname -o)"
# }}}

# Functions {{{

prompt_start() { # {{{
valid_sdate="false"
while [ "${valid_sdate}" = "false" ]; do
  echo -n "Enter start date in the format YYYY-MM-DD HH:MM  "
  read -e -r user_sdate
  if ! [[ ${user_sdate} =~ $dateregex ]]; then
    echo -e "Invalid date format, need YYYY-MM-DD HH:MM"
  elif [[ "${local_os}" = *inux* ]]; then
    if [[ $(date --date="${user_sdate}" +%s) ]]; then # Linux date format
      epoch_sdate="$(date --date="${user_sdate}" +%s)" # Linux date format
        if [[ "${epoch_sdate}" -lt "${efisilogdate}" ]] || [[ "${epoch_sdate}" -gt "${curdate}" ]]; then
          echo -e "Error: Date is out of range"
        else
          valid_sdate="true"
        fi
    fi
  elif [[ "${local_os}" != *inux* ]]; then
    if [[ $(date -j -f "%F %T" "${user_sdate}":00 +%s) ]]; then # FreeBSD date format
      epoch_sdate="$(date -j -f "%F %T" "${user_sdate}":00 +%s)" # FreeBSD date format
        if [[ "${epoch_sdate}" -lt "${efisilogdate}" ]] || [[ "${epoch_sdate}" -gt "${curdate}" ]]; then
          echo -e "Error: Date is out of range"
        else
          valid_sdate="true"
        fi
    fi
  else
    echo -e "Invalid date entered"
  fi
done
}
# }}} End prompt_start

prompt_end(){ # {{{
valid_edate="false"
while [ "${valid_edate}" = "false" ]; do
  echo -n "Enter end date in the format YYYY-MM-DD HH:MM  "
  read -e -r user_edate
  if ! [[ ${user_edate} =~ $dateregex ]]; then
    echo -e "Invalid date format, need YYYY-MM-DD HH:MM"
  elif [[ $(date --date="${user_edate}" +%s) ]]; then # Linux date format
    epoch_edate="$(date --date="${user_edate}" +%s)" # Linux date format
    if [[ "${epoch_edate}" -gt "${curdate}" ]]; then
      echo -e "Error: Date is out of range"
    elif [[ "${epoch_edate}" -lt "${epoch_sdate}" ]]; then
      echo -e "Error: Start date is before end date"
    else
      valid_edate="true"
    fi
  elif [[ $(date -j -f "%F %T" "${user_edate}":00 +%s) ]]; then # FreeBSD date format
    epoch_edate="$(date -j -f "%F %T" "${user_edate}":00 +%s)" # FreeBSD date format
  else
    echo -e "Invalid date entered"
  fi
done
}
# }}} End prompt_end

prompt_sloc(){ # {{{
echo -e "Available domain / Access zones to search are:"
echo -e "[1] CDA\t[6] CDOT\t[11] DORA"
echo -e "[2] CDHA\t[7] CDPHE\t[12] GOV"
echo -e "[3] CDHSHIPAA\t[8] DEPTS\t[13] HCPF"
echo -e "[4] CDLE\t[9] DOLA\t[14] Legislative"
echo -e "[5] CDOC\t[10] DOR\t[15] OIT"
echo -n "Which domain/Access zone are we searching: "
read -e -r user_sloc
}
# }}} End prompt_sloc

prompt_stype(){ # {{{
echo -n "Will this search be for a [U]ser, [D]irectory or [F]ile: "
read -e -r user_stype
case "${user_stype}" in
  U | User)
  echo -n "What AD Domain is the user in: "
  ;;
  D | Directory)
  ;;
  F | File)
  ;;
  *)
  echo -e "Error: Invalid choice, please type:"
  echo -e "U | User for a user based search"
  echo -e "D | Directory for a directory based search"
  echo -e "F | File for a file based search"
  ;;
esac
}
# }}} End prompt_search

# }}} End functions section

# Begin main tasks  {{{
prompt_start
prompt_end
prompt_sloc
prompt_stype
echo -e "Start is: ${user_sdate} - ${epoch_sdate}"
echo -e "End is: ${user_edate} - ${epoch_edate}"
echo -e "Search location is: ${user_sloc}"
echo -e "Search type is: ${user_stype}"
# }}}

exit 0
