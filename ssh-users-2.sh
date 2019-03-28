#!/bin/bash

# Variable definitions # {{{
sshlogfile="/var/log/secure"
resultfile="/home/burgk/ssh-users.txt"
tmplist="/var/tmp/tmplist"
jointlog=/var/tmp/$(date +%B-sshlog.txt)
ltoday="$(date +%b" "%d)"
htoday="$(date +%b"-"%d)"
month=$(date +%B)
checkuser="nomad"
role="node" # "loghost"
me=$(hostname -s)
creds="burgk@vm-debian"
declare -a oraenv=(cdotorman,cdotorprd11,cdotorprd12,cdotorprd14,cdotordev03,cdotordev11,cdotordev12,cdotordev13,cdotortst13,cdotortst14)
# }}}

# Prevent logins during script execution
# echo -e "System temporarily unavailable, please try again after 12:00am" > /etc/nologin

pidlist=$(grep "${ltoday}" "${sshlogfile}" | grep sshd | grep -v grep | grep "${checkuser}" | grep -E "Accepted|session closed" | awk '{print $5}' | tr -d "[:alpha:][:punct:]" | sort -g | uniq)
if [[ -z "${pidlist}" ]]; then
  echo -e "No ${checkuser} logins on ${me} on ${today}" >> "${resultfile}"
  touch /var/tmp/"${me}-${htoday}-false"
  scp /var/tmp/"${me}-${htoday}-false" ${creds}:/var/tmp/
  exit 0
else
  echo -e "${pidlist}" > "${tmplist}"
  while read -r pid; do
    intime=$(grep "${pid}" /var/log/secure | grep Accepted | awk '{print $1" "$2" "$3}')
    srcsrv=$(grep "${pid}" /var/log/secure | grep Accepted | awk '{print $4}')
    inuser=$(grep "${pid}" /var/log/secure | grep Accepted | awk '{print $9}')
    inaddr=$(grep "${pid}" /var/log/secure | grep Accepted | awk '{print $11}')
    outime=$(grep "${pid}" /var/log/secure | grep "session closed" | awk '{print $1" "$2" "$3}')
    if [[ -z "${outime}" ]]; then
      outime="Still logged in"
    else
      outime=$(grep "${pid}" /var/log/secure | grep "session closed" | awk '{print $1" "$2" "$3}')
    fi
    echo -e "${intime}\t${srcsrv}\t${inuser}\t${inaddr}\t${outime}" >> "${resultfile}"
  done < <(cat "${tmplist}")
fi
rm "${tmplist}"

if [[ ${role} == "loghost" ]]; then
  if [[ -e ${jointlog} ]]; then
    logmonth=$(find /var/tmp/*-sshlog.txt | cut -d'-' -f1 | cut -d'/' -f4)
    if [[ "${month}" != "${logmonth}" ]]; then
      mv /var/tmp/$(date -d "-1 month" +%B)-sshlog.txt /root
      touch "${jointlog}"
    echo -e "Login Time\t\tLogin To\tUser\tLogin From\tLogout Time" >> "${jointlog}"
    fi
  else 
    touch "${jointlog}"
    echo -e "Login Time\t\tLogin To\tUser\tLogin From\tLogout Time" >> "${jointlog}"
  fi
  for orahost in "${oraenv[@]}"; do
    if [[ -e /var/tmp/"${orahost}-${today}-true" ]]; then
      cat /var/tmp/"${orahost}-${today}-true" >> "${jointlog}"
      indata="true"
    fi
  done
  if [[ "${indata}" != "true" ]]; then
    echo -e "No ${checkuser} logins in the environment on ${today}" >> "${jointlog}"
  fi
fi

# Clean up
rm /var/tmp/"${me}-${htoday}-false"

# Re-enable logins
# sleep 60
# rm /etc/nologin

exit 0
