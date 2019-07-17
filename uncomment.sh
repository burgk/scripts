#!/usr/bin/env bash
# Purpose: Script to show only uncommented lines in config files
# Date: 20170829
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
pager=bat
# }}} End misc vars

# Begin main tasks {{{
if [[ $EUID != 0 ]]; then
  echo -e "Many files need root privileges to read and you are not root."
  read -rep "Please re-run as root or via sudo, or enter y to continue anyway: " user_reply
fi

case "${user_reply}" in
  y | Y)
    grep -v ^# "${1}" | grep -v ^$ | "${pager}"
  ;;
  n | N)
    echo -e "Ok, exiting"
    exit 1
  ;;
  *)
    echo -e "Unrecognized input! Exiting!"
    exit 1
  ;;
esac

exit 0
# }}} End main tasks
