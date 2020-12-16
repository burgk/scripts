#!/bin/bash
# Purpose: Quick script to update a directory of git repositories
# Date: 20201216
# Kevin Burg - burg.kevin@gmail.com

# Misc variable definitions {{{
f_red="\e[38;2;255;0;0m"
f_green="\e[38;2;0;255;0m"
reset="\e[0m"
# }}}

updaterepo() { # {{{
for dir in $(ls "${repopath}")
 do echo -e "${f_green}Running git pull in: ${dir}${reset}"
 git -C "${repopath}/${dir}" pull
done
} # }}}

usage() { # {{{
echo -e "${f_red}USAGE: Enter a single, full path to a collection of git repos${reset}"
exit 1
} # }}}

patherr() { # {{{
echo -e "${f_red}ERROR: Specified path does not exist${reset}"
exit 1
} # }}}

getpath() { #{{{
read -rep "Enter path: " repopath
} # }}}

# Begin main tasks {{{
if [[ "$#" -eq 0 ]]; then
  getpath
  if [ -d "${repopath}" ]; then
    updaterepo
  else
    patherr
  fi
elif [[ "$#" -eq 1 ]]; then
  if [ -d "${1}" ]; then
    repopath="${1}"
    updaterepo
  else
    patherr
  fi
else
  echo -e "${f_red}Can only process a single path at this time${reset}"
fi
exit 0
# }}}
