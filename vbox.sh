#!/usr/bin/env bash
# Kevin Burg - burg.kevin@gmail.com
# Script to query status and start/stop specific VirtualBox VMs

VBOX=VBoxManage.exe

# Set color constants
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
MAGENTA="\033[1;35m"
CYAN="\033[1;36m"
WHITE="\033[1;37m"
BOLD="\033[1m"
RESET="\033[0m"

if [ "$1" = "list" ]
then
#	"${VBOX}" list vms | cut -d"{" -f 1
	"${VBOX}" list vms | awk -F\" '{ print $2 }'
	exit 0
elif [ "$1" = "status" ]
then
    for vm in $(vbox.sh list)
    do
      if [ $("${VBOX}" showvminfo ${vm} | grep State | awk '{ print $2 }') = "running" ]
      then
        echo -e "${vm}" ":${GREEN} running${RESET}"
      else
        echo -e "${vm}" "${RED}: powered off${RESET}"
      fi
    done
   exit 0
# elif [ "$1" = "status" ]
# then
# 	if [ $# = 1 ]
# 	then
# 		echo -e "Status requires a VM name, use list to get the list of VMs"
# 	else
# 		if [ $("${VBOX}" showvminfo "$2" | grep State | awk '{ print $2 }') = "running" ]
# 		then
# 			echo -e "$2" "is currently running"
# 		else
# 			echo -e "$2" "is currently powered off"
# 		fi
#  	exit 0
#	fi
elif [ "$1" = "start" ] 
then
	if [ $# = 1 ]
	then
		echo -e "Start requires a VM name to start, use list to get the list of VMs"
	else
		if [ $("${VBOX}" showvminfo "$2" | grep State | awk '{ print $2 }') = "running" ]
		then
			echo -e "$2" "is already running"
		else
		"${VBOX}" startvm $2 --type headless
		fi
	fi
elif [ "$1" = "stop" ]
then
	if [ $# = 1 ]
	then
		echo -e "Stop requires a VM name to stop, use list to get the list of VMs"
	else
		if [ $("${VBOX}" showvminfo "$2" | grep State | awk '{ print $2 }') = "powered" ]
		then
			echo -e "$2" "is already powered off"
		else
		"${VBOX}" controlvm $2 poweroff 
		fi
	fi
fi
