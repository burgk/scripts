#!/usr/bin/env bash
# Purpose: Script to show only uncommented lines in config files
# Date: 20170829
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
pager1="/usr/bin/bat"
pager2="/usr/bin/less"
termsize="$(tput lines)"
# }}} End misc vars

# Begin main tasks {{{
if [[ $EUID -ne 0 ]]; then
  echo -e "Many files need root privileges to read and you are not root."
  read -rep "Please re-run as root or via sudo, or enter y to continue anyway: " user_reply
fi

if [[ $(command -v "${pager1}") ]]; then
  pager="${pager1}"
elif [[ $(command -v "${pager2}") ]]; then
  pager="${pager2}"
fi

if [[ "${user_reply}" == "y" ]]; then
  output=$(grep -v -e '^ *#' -e '^$' "${1}")
  outsize=$(wc -l "${output}")
  if [[ "${outsize}" -ge "${termsize}" ]]; then
    "${pager}" "${output}"
  else
    cat "${output}"
  fi
else
  echo -e "Ok, exiting"
  exit 1
fi
exit 0
# }}} End main tasks
