#!/bin/bash
# Purpose: Quick script to update git repository vim packages.
#          Can update packages in pathogen or native paths
#          For native it assumes the username is used in the path
# Date:20181120
# Kevin Burg - burg.kevin@gmail.com

# Misc variable definitions {{{
f_red="\e[38;2;255;0;0m"
f_green="\e[38;2;0;255;0m"
reset="\e[0m"
# }}}

updatepkg() { # {{{
 for dir in $(ls "${pkgpath}")
  do cd "$pkgpath"/"${dir}" || break
  echo -e "${f_green}Running git pull in ${dir}:${reset}"
  git pull
  cd ..
 done
} # }}}

usage() { # {{{
 echo -e "${f_red}Requires option of --native|-n or --pathogen|-p depending on which you are using"
 echo -e "Typically vim 8+ uses native. I assume you are using your username"
 echo -e "In the native package path.${reset}"
 exit 1
} # }}}

patherr() { # {{{
 echo -e "${f_red}Specified path does not exist${reset}"
 exit 1
} # }}}

# Begin main tasks {{{
case ${1} in
 --native | -n)
   if [ -d /home/"${USER}"/.vim/pack/"${USER}"/start ]; then
    pkgpath=/home/"${USER}"/.vim/pack/"${USER}"/start
    updatepkg
   else
    patherr
   fi
   ;;
 --pathogen | -p)
   if [ -d /home/"${USER}"/.vim/bundle ]; then
    pkgpath=/home/"${USER}"/.vim/bundle
    updatepkg
   else
    patherr
   fi
   ;;
 *)
   usage
   ;;
esac # }}}

exit 0
