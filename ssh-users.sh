#!/bin/bash
# Script to record who logs in to a server and how
# Runs daily from crontab
# Copy to roots homedir then add the following to /etc/crontab
# 58 23 * * * root /root/ssh-users.sh
# Kevin Burg - kevin.burg@state.co.us

logfile="/var/log/secure"
resultfile="/home/serveradmin/ssh-users.txt"
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


