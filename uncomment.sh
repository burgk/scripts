#!/usr/bin/env bash
# Script to show only uncommented lines in config files

if [ $EUID -ne 0 ]
  then
    echo -e "Please re-run as root or via sudo"
    exit 1
else
  grep -v ^# ${1} | grep -v ^$ | less
fi

exit 0
