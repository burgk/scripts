#!/usr/bin/bash
# Purpose: Wrapper to parse through isi_audit_viewer data
# Date: 2019-04-19
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
f_red="\e[1;31m"
f_green="\e[1;32m"
reset="\e[0m"
num='^[0-9]+$'
# nodecount=$(ls /ifs/.ifsvar/audit/logs | grep -c node)
# isi_log_start="2016-03-15"
valid_sdate="false"
s_year="2015"
s_month="12"
s_day="17"
s_hour="14"
s_minute="49"
s_second="00"
user_ssec="00"
s_unixtime=""
e_year=""
e_month=""
e_day=""
e_hour=""
e_minute=""
e_second="00"
user_esec="00"
e_unixtime=""
c_year=$(date +%Y)
c_month=$(date +%m)
c_day=$(date +%d)
# }}}

# Functions {{{

display_header(){ #{{{
  echo -e "${f_green}"
  echo -e "****************************************"
  echo -e "**  ISILON AUDIT DATA SEARCH UTILITY  **"
  echo -e "****************************************"
  echo -e "${reset}"
  echo -e "Currently, logs on EFX400 go back to"
  echo -e "Dec 17 2015 at 14:48:32 MST"
  echo -e "Since the unzipped log files can take"
  echo -e "up a great deal of space and time to"
  echo -e "parse through, the smaller you can make"
  echo -e "the time range searched through the better"
  echo -e "this utility will work\n"
} #}}}

prompt_syear(){ #{{{
valid_syear="false"
while [ "${valid_syear}" = "false" ]; do
  echo -n "Start year [YYYY]: "
  read -e -r user_syear
  if ! [[ "${user_syear}" =~ ${num} ]]; then
    echo "Invalid data type, number expected"
  elif [[ "${user_syear}" -lt "2015" ]] || [[ "${user_syear}" -gt "${c_year}" ]]; then
    echo -e "Year entered out of range"
  else
    valid_syear="true"
  fi
done
} #}}} End prompt_syear

prompt_smonth(){ #{{{
valid_smonth="false"
while [ "${valid_smonth}" = "false" ]; do
  echo -n "Start month [MM]: "
  read -e -r user_smonth
  size_smonth="${#user_smonth}"
  if ! [[ "${user_smonth}" =~ ${num} ]]; then
    echo -e "Invalid data type, number expected"
  elif (( "${size_smonth}" != 2 )); then
    echo -e "Need 2 digit month"
  elif (( "${user_smonth#0}" > "12" )); then
    echo -e "Invalid month entered"
  else
    valid_smonth="true"
  fi
done
} # }}} End prompt_smonth

prompt_sday(){ #{{{
valid_sday="false"
while [ "${valid_sday}" = "false" ]; do
  echo -n "Start day [DD]: "
  read -e -r user_sday
  size_sday="${#user_sday}"
  if ! [[ "${user_sday}" =~ ${num} ]]; then
    echo -e "Invalid data type, number expected"
  elif (( "${size_sday}" != 2 )); then
    echo -e "Need 2 digit month"
  else
    case "${user_smonth}" in
    01 | 03 | 05 | 07 | 08 | 10 | 12)
      if (( "${user_sday#0}" > "31" )); then
        echo -e "Invalid day entered for month ${user_smonth}"
      else
        valid_sday="true"
      fi
    ;;
    04 | 06 | 09 | 11)
      if (( "${user_sday#0}" > "30" )); then
        echo -e "Invalid day entered for month ${user_smonth}"
      else
        valid_sday="true"
      fi
    ;;
    02)
      yearmod=$(( "${user_syear}" % 4 ))
      if (( "${yearmod}" == "0" )); then # leap year
        if (( "${user_sday#0}" > "29" )); then # 29 days in a leap year
          echo -e "Invalid day entered for month ${user_smonth}"
        else
          valid_sday="true"
        fi
      else # not a leap year
        if (( "${user_sday#0}" > "28" )); then # 28 days in non leap years
          echo -e "Invalid day entered for month ${user_smonth}"
        else
          valid_sday="true"
        fi
      fi
    ;;
    esac
  fi
done
} #}}} End prompt_sdate

prompt_shour(){ #{{{
valid_shour="false"
while [ "${valid_shour}" = "false" ]; do
  echo -n "Start hour in 24H notation: "
  read -e -r user_shour
  if ! [[ "${user_shour}" =~ ${num} ]]; then
    echo -e "Invalid data type, number expected"
  elif (( "${user_shour#0}" > "23" )); then
    echo -e "Invalid hour entered"
  else
    valid_shour="true"
  fi
done
} #}}} End prompt_shour

prompt_smin(){ #{{{
valid_smin="false"
while [ "${valid_smin}" = "false" ]; do
  echo -n "Start minutes: "
  read -e -r user_smin
  if ! [[ "${user_smin}" =~ ${num} ]]; then
    echo "Invalid data type, number expected"
  elif (( "${user_smin#0}" > "59" )); then
    echo -e "Invalid minute entered"
  else
    valid_smin="true"
  fi
done
} #}}} End prompt_smin

prompt_eyear(){ #{{{
valid_eyear="false"
while [ "${valid_eyear}" = "false" ]; do
  echo -n "End year [YYYY]: "
  read -e -r user_eyear
  if ! [[ "${user_eyear}" =~ ${num} ]]; then
    echo "Invalid data type, number expected"
  elif (( "${user_eyear}" < "2015" )) || (( "${user_eyear}" > "${c_year}" )); then
    echo -e "Year entered out of range"
  elif (( "${user_eyear}" < "${user_syear}" )); then
    echo -e "End year must be equal to or greater than start year"
  else
    valid_eyear="true"
  fi
done
} #}}} End prompt_eyear

prompt_emonth(){ #{{{
valid_emonth="false"
while [ "${valid_emonth}" = "false" ]; do
  echo -n "End month [MM]: "
  read -e -r user_emonth
  size_emonth="${#user_emonth}"
  if ! [[ "${user_emonth}" =~ ${num} ]]; then
    echo -e "Invalid data type, number expected"
  elif (( "${size_emonth}" != "2" )); then
    echo -e "Use 2 digits for month please"
  elif (( "${user_emonth#0}" > "12" )); then
    echo -e "Invalid month entered"
  fi
  if (( "${user_eyear}" >= "${user_syear}" )); then
    if (( "${user_emonth#0}" >= "${user_smonth#0}" )); then
#      echo -e "End month must be equal to or greater than start month"
      valid_emonth="true"
    fi
#  else
#    valid_emonth="true"
  fi
done
} # }}} End prompt_emonth

prompt_eday(){ #{{{
valid_eday="false"
while [ "${valid_eday}" = "false" ]; do
  echo -n "End day [DD]: "
  read -e -r user_eday
  size_eday="${#user_eday}"
  if ! [[ "${user_eday}" =~ ${num} ]]; then
    echo -e "Invalid data type, number expected"
  elif (( "${size_eday}" != 2 )); then
    echo -e "Need 2 digit month"
  else
    case "${user_emonth}" in
    01 | 03 | 05 | 07 | 08 | 10 | 12)
      if (( "${user_eday#0}" > "31" )); then
        echo -e "Invalid day entered for month ${user_emonth}"
      elif (( "${user_eyear}" >= "${user_syear}" )); then
        if (( "${user_emonth#0}" >= "${user_smonth#0}" )); then
          if (( "${user_eday#0}" >= "${user_sday#0}" )); then
            valid_eday="true"
          fi
        fi
      fi
    ;;
    04 | 06 | 09 | 11)
      if (( "${user_eday#0}" > "30" )); then
        echo -e "Invalid day entered for month ${user_emonth}"
      elif (( "${user_eyear}" >= "${user_syear}" )); then
        if (( "${user_emonth#0}" >= "${user_smonth#0}" )); then
          if (( "${user_eday#0}" >= "${user_sday#0}" )); then
            valid_eday="true"
          fi
        fi
      fi
    ;;
    02)
      yearmod=$(( "${user_eyear}" % 4 ))
      if (( "${yearmod}" == "0" )); then # leap year
        if (( "${user_eday#0}" > "29" )); then # 29 days in a leap year
          echo -e "Invalid day entered for month ${user_emonth}"
        elif (( "${user_eyear}" >= "${user_syear}" )); then
          if (( "${user_emonth#0}" >= "${user_smonth#0}" )); then
            if (( "${user_eday#0}" >= "${user_sday#0}" )); then
              valid_eday="true"
            fi
          fi
        fi
      else # not a leap year
        if (( "${user_eday#0}" > "28" )); then # 28 days in non leap years
          echo -e "Invalid day entered for month ${user_emonth}"
        elif (( "${user_eyear}" >= "${user_syear}" )); then
          if (( "${user_emonth#0}" >= "${user_smonth#0}" )); then
            if (( "${user_eday#0}" >= "${user_sday#0}" )); then
              valid_eday="true"
            fi
          fi
        fi
      fi
    ;;
    esac
  fi
done
} #}}} End prompt_eday

prompt_ehour(){ #{{{
valid_ehour="false"
while [ "${valid_ehour}" = "false" ]; do
  echo -n "End hour in 24H notation: "
  read -e -r user_ehour
  if ! [[ "${user_ehour}" =~ ${num} ]]; then
    echo -e "Invalid data type, number expected"
  elif (( "${user_ehour#0}" > "23" )); then
    echo -e "Invalid hour entered"
  elif (( "${user_ehour#0}" < "${user_shour#0}" )); then
    echo -e "End hour must be equal to or greater than start hour"
  else
    valid_ehour="true"
  fi
done
} #}}} End prompt_ehour

prompt_emin(){ #{{{
valid_emin="false"
while [ "${valid_emin}" = "false" ]; do
  echo -n "End minutes: "
  read -e -r user_emin
  if ! [[ "${user_emin}" =~ ${num} ]]; then
    echo "Invalid data type, number expected"
  elif (( "${user_emin#0}" > "59" )); then
    echo -e "Invalid minute entered"
  elif (( "${user_emin#0}" <= "${user_smin#0}" )); then
    echo -e "End minute must be greater than start minute"
  else
    valid_emin="true"
  fi
done
} #}}} End prompt_smin

#}}}

# Begin main tasks {{{
# display_header
prompt_syear
prompt_smonth
prompt_sday
# prompt_shour
# prompt_smin
prompt_eyear
prompt_emonth
prompt_eday
# prompt_ehour
# prompt_emin

echo -e "Start: ${user_syear}-${user_smonth}-${user_sday}" #  ${user_shour}:${user_smin}"
echo -e "End: ${user_eyear}-${user_emonth}-${user_eday}" # ${user_ehour}:${user_emin}"
#}}}

exit 0
