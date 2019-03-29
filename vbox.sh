#!/usr/bin/env bash
# Purpose: Script to query status and start/stop specific VirtualBox VMs
# Date: 20181024
# Kevin Burg - burg.kevin@gmail.com

# Misc variable definitions {{{
vbox=VBoxManage.exe
# }}}

# Terminal color definitions {{{
# red="\033[1;31m"
red="\e[38;2;255;0;0m"
# green="\033[1;32m"
green="\e[38;2;0;255;0m"
yellow="\033[1;33m"
blue="\033[1;34m"
magenta="\033[1;35m"
cyan="\033[1;36m"
white="\033[1;37m"
bold="\033[1m"
reset="\033[0m"
# }}}

# Begin main tasks {{{
if [ "$1" = "list" ]
then
	"${vbox}" list vms | awk -F\" '{ print $2 }'
	exit 0
elif [ "$1" = "status" ]
then
    for vm in $(vbox.sh list)
    do
      if [ $("${vbox}" showvminfo ${vm} | grep State | awk '{ print $2 }') = "running" ]
      then
        echo -e "${vm}:" "${green} running${reset}"
      else
        echo -e "${vm}:" "${red} powered off${reset}"
      fi
    done
   exit 0
elif [ "$1" = "start" ] 
then
	if [ $# = 1 ]
	then
		echo -e "Start requires a VM name to start, use list to get the list of VMs"
	else
		if [ $("${vbox}" showvminfo "$2" | grep State | awk '{ print $2 }') = "running" ]
		then
			echo -e "$2" "is already running"
		else
		"${vbox}" startvm $2 --type headless
		fi
	fi
elif [ "$1" = "stop" ]
then
	if [ $# = 1 ]
	then
		echo -e "Stop requires a VM name to stop, use list to get the list of VMs"
	else
		if [ $("${vbox}" showvminfo "$2" | grep State | awk '{ print $2 }') = "powered" ]
		then
			echo -e "$2" "is already powered off"
		else
		"${vbox}" controlvm $2 poweroff 
		fi
	fi
fi
# }}}

exit 0
