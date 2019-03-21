#!/bin/bash
# Script to record who logs in to a server and how
# Kevin Burg - kevin.burg@state.co.us

# Runs daily from crontab
# Copy to roots homedir then add the following to /etc/crontab
# 59 23 * * * root /root/ssh-users.sh

logfile="/var/log/secure"
resultfile="/home/serveradmin/ssh-users.txt"
today="$(date +%b" "%d)"
checkuser="oracle"

if [ -e "${logfile}" ]; then
  echo -e "--------------------------------------" >> "${resultfile}"
  echo -e "Login summary for ${checkuser} on: $(date +%F)" >> "${resultfile}"
  echo -e "--------------------------------------" >> "${resultfile}"
  if grep -w "${today}" "${logfile}" | grep "Accepted" | grep -i "${checkuser}" > /dev/null 2>&1; then
    grep -w "${today}" "${logfile}" | grep "Accepted" | grep -i "${checkuser}" >> "${resultfile}"
    echo -e "\n" >> "${resultfile}"
  else
    echo -e "No "${checkuser}" logins recorded today\n" >> "${resultfile}"
  fi
else
  echo -e "ERROR - $(date +%F): Log file not found" >> "${resultfile}"
  logger "ssh-users.sh: Error - Log file not found"
  exit 1
fi
exit 0
