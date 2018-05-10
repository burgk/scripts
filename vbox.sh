#!/usr/bin/env bash
# Script to query status and start/stop specific VirtualBox VMs

VBOX=VBoxManage.exe

if [ "$1" = "list" ]
then
	"${VBOX}" list vms | cut -d"{" -f 1
	exit 0
elif [ "$1" = "status" ]
then
	if [ $# = 1 ]
	then
		echo -e "Status requires a VM name, use list to get the list of VMs"
	else
		if [ $("${VBOX}" showvminfo "$2" | grep State | awk '{ print $2 }') = "running" ]
		then
			echo -e "$2" "is currently running"
		else
			echo -e "$2" "is currently powered off"
		fi
	exit 0
	fi
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
