#!/bin/bash
# Script to record who logs in to a server and how
# Kevin Burg - kevin.burg@state.co.us

# Runs daily from crontab
# Copy to roots homedir then add the following to /etc/crontab
# 59 23 * * * root /root/ssh-users.sh

# Variable definitions # {{{
logfile="/var/log/secure"
resultfile="/home/serveradmin/ssh-users.txt"
today="$(date +%b" "%d)"
checkuser="oracle"
# }}}

# prevent logins during script execution
echo -e "System temporarily unavailable, please try again in 5 minutes" > /etc/nologin

declare -a logpid=$(grep "${today}" "${logfile}" | grep sshd | awk '{print $5}' | tr -d [:alpha:][:punct:] | uniq)
for pid in "${logpid[@]}"; do
  intime=$(grep "${pid}" /var/log/secure | grep Accepted | awk '{print $3}')
  srcsrv=$(grep "${pid}" /var/log/secure | grep Accepted | awk '{print $4}')
  inuser=$(grep "${pid}" /var/log/secure | grep Accepted | awk '{print $9}')
  inaddr=$(grep "${pid}" /var/log/secure | grep Accepted | awk '{print $11}')
  outime=$(grep "${pid}" /var/log/secure | grep "session closed" | awk '{print $3}')
  echo -e "${intime} \t ${srcsrv} \t ${inuser} \t ${inaddr} \t ${outime}" >> "${resultfile}"


if [ -e "${logfile}" ]; then
  echo -e "--------------------------------------" >> "${resultfile}"
  echo -e "Login summary for ${checkuser} on: $(date +%F)" >> "${resultfile}"
  echo -e "--------------------------------------" >> "${resultfile}"
  if grep -w "${today}" "${logfile}" | grep "Accepted" | grep -i "${checkuser}" > /dev/null 2>&1; then
    grep -w "${today}" "${logfile}" | grep "Accepted" | grep -i "${checkuser}" >> "${resultfile}"
    echo -e "\n" >> "${resultfile}"
  else
    echo -e "No ${checkuser} logins recorded today\n" >> "${resultfile}"
  fi
else
  echo -e "ERROR - $(date +%F): Log file not found" >> "${resultfile}"
  logger "ssh-users.sh: Error - Log file not found"
  exit 1
fi
# re-enable logins
rm /etc/nologin

exit 0
