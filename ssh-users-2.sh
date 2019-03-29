#!/bin/bash
# Script to record who logs in to a server and how
# Kevin Burg - kevin.burg@state.co.us

# Runs daily from crontab
# Copy to roots homedir then add the following to /etc/crontab
# 58 23 * * * root /root/ssh-users.sh <-- for node role
# 59 23 * * * root /root/ssh-users.sh <-- for loghost role

# Variable definitions # {{{
# For loghosts, verify or set sshlogfile, checkuser and role as necessary
ltoday="$(date +%b" "%d)"
htoday="$(date +%b"-"%d)"
month=$(date +%B)
me=$(hostname -s)
sshlogfile="/var/log/secure" # /var/log/secure on redhat - /var/log/auth.log on debian
resultfile="/home/burgk/ssh-users.txt"
tmpresult="/home/burgk/tmp.out"
truetmpresult="/var/tmp/${me}-${htoday}-true"
falsetmpresult="/var/tmp/${me}-${htoday}-false"
tmppidlist="/var/tmp/tmppidlist"
jointlog=/var/tmp/$(date +%B-sshlog)
checkuser="nomad"
role="node" # "loghost" or "node"
creds="burgk@vm-debian"
declare -a vmenv=(vm-fedora vm-debian)
# declare -a oraenv=(cdotorman cdotorprd11 cdotorprd12 cdotorprd14 cdotordev03 cdotordev11 cdotordev12 cdotordev13 cdotortst13 cdotortst14)
# }}}

# Prevent logins during script execution {{{
# echo -e "System temporarily unavailable, please try again after 12:00am" > /etc/nologin
# }}} 

# Verify persistent log exists {{{
if [[ ! -e "${resultfile}" ]]; then
  echo -e "Login Time;Login To;Login User;Login From;Logout Time" > "${tmpresult}"
  echo -e "---------------;------------;------------;---------------;---------------" >> "${tmpresult}"
  column -s";" -t < "${tmpresult}" > "${resultfile}"
  rm "${tmpresult}"
fi # }}}

# Begin processing logins {{{
pidlist=$(grep "${ltoday}" "${sshlogfile}" | grep sshd | grep -v grep | grep "${checkuser}" | grep -E "Accepted|session closed" | awk '{print $5}' | tr -d "[:alpha:][:punct:]" | sort -g | uniq)
if [[ -z "${pidlist}" ]]; then
  echo -e "No ${checkuser} logins on ${me} on ${ltoday}" >> "${resultfile}"
  touch "${falsetmpresult}"
  if [[ "${role}" == "node" ]]; then
    scp "${falsetmpresult}" "${creds}":/var/tmp/
  fi
else
  echo -e "${pidlist}" > "${tmppidlist}"
  while read -r pid; do
    intime=$(grep -w "${pid}" "${sshlogfile}" | grep Accepted | awk '{print $1" "$2" "$3}')
    if [[ -z "${intime}" ]]; then
      intime="Prior login"
    fi
    srcsrv=$(grep -w "${pid}" "${sshlogfile}" | grep Accepted | awk '{print $4}')
    if [[ -z "${srcsrv}" ]]; then
      srcsrv="Prior login"
    fi
    inuser=$(grep -w "${pid}" "${sshlogfile}" | grep Accepted | awk '{print $9}')
    if [[ -z "${inuser}" ]]; then
      inuser="Prior login"
    fi
    inaddr=$(grep -w "${pid}" "${sshlogfile}" | grep Accepted | awk '{print $11}')
    if [[ -z "${inaddr}" ]]; then
      inaddr="Prior login"
    fi
    outime=$(grep -w "${pid}" "${sshlogfile}" | grep "session closed" | awk '{print $1" "$2" "$3}')
    if [[ -z "${outime}" ]]; then
      outime="Still logged in"
    fi
    echo -e "${intime};${srcsrv};${inuser};${inaddr};${outime}" >> "${resultfile}"
    echo -e "${intime};${srcsrv};${inuser};${inaddr};${outime}" >> "${truetmpresult}"
  done < <(cat "${tmppidlist}")
  if [[ "${role}" == "node" ]]; then
    scp "${truetmpresult}" "${creds}":/var/tmp
  fi
fi
if [[ -e "${tmppidlist}" ]]; then
  rm "${tmppidlist}"
fi # Exit PID processing }}}

# Begin processing loghost tasks {{{
if [[ "${role}" == "loghost" ]]; then
  if [[ -e ${jointlog} ]]; then
    logmonth=$(find /var/tmp/*-sshlog | cut -d'-' -f1 | cut -d'/' -f4)
    if [[ "${month}" != "${logmonth}" ]]; then
      touch "${jointlog}"
      echo -e "Login Time;Login To;Login User;Login From;Logout Time" > "${jointlog}"
      echo -e "---------------;------------;------------;---------------;---------------" >> "${jointlog}"
    fi
  else 
    touch "${jointlog}"
    echo -e "Login Time;Login To;User;Login From;Logout Time" > "${jointlog}"
    echo -e "---------------;------------;------------;---------------;---------------" >> "${jointlog}"
  fi

#  for orahost in "${oraenv[@]}"; do
#    if [[ -e /var/tmp/"${orahost}-${htoday}-true" ]]; then
#      cat /var/tmp/"${orahost}-${htoday}-true" >> "${jointlog}"
#      rm /var/tmp/"${orahost}-${htoday}-true"
#      indata="true"
#    elif [[ -e /var/tmp/"${orahost}-${htoday}-false" ]]; then
#      rm /var/tmp/"${orahost}-${htoday}-false"
#    fi
#  done

  for vmhost in "${vmenv[@]}"; do
    if [[ -e /var/tmp/"${vmhost}-${htoday}-true" ]]; then
      cat /var/tmp/"${vmhost}-${htoday}-true" >> "${jointlog}"
      rm /var/tmp/"${vmhost}-${htoday}-true"
      indata="true"
    elif [[ -e /var/tmp/"${vmhost}-${htoday}-false" ]]; then
      rm /var/tmp/"${vmhost}-${htoday}-false"
    fi
  done

  if [[ "${indata}" != "true" ]]; then
    echo -e "No ${checkuser} logins in the environment on ${ltoday}" >> "${jointlog}"
  fi
fi # Exit loghost }}}

# Clean up {{{
if [[ -e "${falsetmpresult}" ]]; then
  rm "${falsetmpresult}"
fi

if [[ -e "${truetmpresult}" ]]; then
  rm "${truetmpresult}"
fi

if [[ "${role}" == "loghost" ]]; then
archivemonth="$(date --date="$(date +%Y-%m-15) -2 month" +%B)"
  if [[ -e /var/tmp/"${archivemonth}-sshlog" ]]; then
    mv /var/tmp/"${archivemonth}-sshlog" /root
  fi
fi # }}}

# Re-enable logins {{{
# if [[ "${role}" == "node" ]]
# sleep 120
# rm /etc/nologin
# else
#   sleep 60
#   rm /etc/nologin
# fi }}}

exit 0
