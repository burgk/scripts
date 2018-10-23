#!/bin/env bash
# Quick script to update git repository vim packages.
# Can update packages in pathogen or native  paths
# For native it assumes the username is used in the path

F_RED="\e[38;2;255;0;0m"
F_GREEN="\e[38;2;0;255;0m"
RESET="\e[0m"

updatepkg()
{
 for DIR in $(ls ${PKGPATH})
  do cd $PKGPATH/${DIR}
  echo -e "${F_GREEN}Running git pull in ${DIR}:${RESET}"
  git pull
  cd ..
 done
}

usage()
{
 echo -e "${F_RED}Requires option of native|n or pathogen|p depending on which you are using"
 echo -e "Typically vim 8+ uses native and I assume you are using your username"
 echo -e "In the native package path.${RESET}"
 exit 1
}

patherr()
{
 echo -e "${F_RED}Specified path does not exist${RESET}"
 exit 1
}

case ${1} in
 native | n | -n)
   if [ -d /home/${USER}/.vim/pack/${USER}/start ]
   then
    PKGPATH=/home/${USER}/.vim/pack/${USER}/start
    updatepkg
   else
    patherr
   fi
   ;;
 pathogen | p | -p)
   if [ -d /home/${USER}/.vim/bundle ]
   then
    PKGPATH=/home/${USER}/.vim/bundle
    updatepkg
   else
    patherr
   fi
   ;;
 *)
   usage
   ;;
esac
exit 0
