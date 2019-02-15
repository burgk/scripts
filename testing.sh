#!/bin/bash

get_args() { #{{{
echo -e "Argument passed to function at beginning of function: "$1" "
  case "$1" in
  1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12 | 13 | 14 | 15 | 16 | 17 | 18 | 19)
    cliarg="$1"
    echo -e "Parameter entered: ${cliarg}"
    ;;
  *)
    echo -e "Not an expected value, exiting."
    exit 1
    ;;
  esac
} #}}}

if [[ "$#" -eq 1 ]]; then
  echo -e "Calling get_args.."
  get_args "$1"
else
  echo -e "No args passed to script"
fi
exit 0
