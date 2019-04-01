#!/usr/bin/env bash
# Purpose: Send Ctrl-Alt-Del to a vm running under KVM on Linux
# Date: 
# Kevin Burg - burg.kevin@gmail.com

if [ $EUID -ne 0 ]; then
  echo -e "Please re-run as root or via sudo"
  exit 1
elif [ $# -ne 1 ]; then
  echo -e "Please supply a vm name"
  exit 1
else
  echo -e "Sending Ctrl-Alt-Del to ${1}"
  virsh send-key ${1} --codeset linux --holdtime 1000 KEY_LEFTCTRL KEY_LEFTALT KEY_DELETE
  echo -e "Done"
  exit 0
fi
