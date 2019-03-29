#!/bin/bash
# Purpose: Format the ssh-users.sh output for reading
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
month=$(date +%B)
premonth="$(date --date="$(date +%Y-%m-15) -1 month" +%B)"
logfile="/var/tmp/${month}-sshlog"
prelogfile="/var/tmp/${premonth}-sshlog"
f_yellow="\e[33m"
reset="\e[0m"
# }}}

usage() { # {{{
  echo -e "${f_yellow}This script will read the current or previous months log file"
  echo -e "For the current month use: --current or -c"
  echo -e "For the previous month use: --previous or -p"
  echo -e "To save the output redirect to a file via >"
  echo -e "For example: ./readlog.sh -c > March-log.txt${reset}"
  exit 1
} # }}}
if [[ "$#" -eq "1" ]]; then
  case "$1" in
   --current | -c)
      if [[ -e "${logfile}" ]]; then
        column -s";" -t < "${logfile}"
      else
        echo -e "Sorry, the log file for ${month} does not seem to exist"
      fi
    ;;
    --previous | -p)
      if [[ -e "${prelogfile}" ]]; then
        column -s";" -t < "${prelogfile}"
      else
        echo -e "Sorry, the log file for ${premonth} does not seem to exist"
      fi
    ;;
    *)
      usage
    ;;
  esac
else
  usage
fi
exit 0

