#!/bin/bash

configfile="/opt/splunkforwarder/etc/system/local/deploymentclient.conf"

# For use as a Tanium package, no need to check for EUID
# Verify we are root
# if (( ${EUID} != 0 )); then
#     echo -e "ERROR: You need to use sudo or be root to run this script"
#     echo -e "For example: sudo ./$(basename ${0})"
#     exit 1
# fi

# Verify config file exists, modify and restart splunk
if [[ -e "${configfile}" ]]; then
	sed -i "s/10.24.11.73/10.23.11.111/" "${configfile}"
	/etc/init.d/splunk restart
	exit 0
fi
# else
# 	echo -e "ERROR: Configuration file not found"
# 	exit 1
# fi
