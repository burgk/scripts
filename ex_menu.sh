#!/usr/bin/bash
# Purpose: Example script of a menu
# Date: 20190418
# Kevin Burg - kevin.burg@state.co.us
# Note: Add an exec <scriptname.sh> to users .bashrc and 
# they will only get this menu, without the exec
# they can exit the menu to bash. This only traps
# Ctrl-c, other signals still work e.g. Ctrl-z

trap '' 2
while true; do
  clear
  echo "========================="
  echo "Menu ----"
  echo "========================="
  echo "Enter 1 to list users 1: "
  echo "Enter 2 to show calendar 2: "
  echo "Enter q to exit the menu q: "
  echo -e "\n"
  read -rep "Enter your selection: " answer
#  read -r answer
  case "${answer}" in
    1)
      who
      uptime
    ;;
    2)
      cal
    ;;
    q)
      exit
    ;;
  esac
  echo -e "Enter return to continue \c"
  read -r input
done
