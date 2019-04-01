#!/usr/bin/env bash
# Purpose: Script to show only uncommented lines in config files
# Date: 20170829
# Kevin Burg - kevin.burg@state.co.us

# Begin main tasks {{{
if (( $EUID != 0 )); then
  echo -e "Please re-run as root or via sudo"
  exit 1
else
  grep -v ^# "${1}" | grep -v ^$ | less
fi # }}}

exit 0
