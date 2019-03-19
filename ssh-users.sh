#!/bin/bash
# Script to log who logs in to Oracle servers and how
# Runs daily from /etc/cron.daily
# Kevin Burg - kevin.burg@state.co.us

logfile="/var/log/secure"
resultfile="/home/burgk/ssh-users.txt"
today="$(date +%b" "%d)"

if [ -e "${logfile}" ]; then
  echo -e "-----------------------------" >> "${resultfile}"
  echo -e "Login Summary for: $(date +%F)" >> "${resultfile}"
  echo -e "-----------------------------" >> "${resultfile}"
  grep -w "${today}" "${logfile}" | grep "Accepted" | grep -v grep  >> "${resultfile}"
else
  echo -e "ERROR: Log file not found!" >> "${resultfile}"
  logger "ssh-users.sh: Error - Log file not found"
  exit 1
fi


