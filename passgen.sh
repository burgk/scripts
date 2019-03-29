#!/bin/bash
# Purpose: Wrapper to run password generator script with some entries set
# Date: 20180321
# Kevin Burg - burg.kevin@gmail.com
 
# Comments {{{
# runpg.sh - # other option include:
# alnum, alpha, blank, cntrl, digit, graph, print, space, xdigit
# see man tr for details
# }}}

# Set colors {{{
# Set 8 bit foreground colors
f_black="\e[1;30m"
f_red="\e[1;31m"
f_green="\e[1;32m"
f_yellow="\e[1;33m"
f_blue="\e[1;34m"
f_magenta="\e[1;35m"
f_cyan="\e[1;36m"
f_white="\e[1;37m"

# Set 8 bit background colors
b_black="\e[1;40m"
b_red="\e[1;41m"
b_green="\e[1;42m"
b_yellow="\e[1;43m"
b_blue="\e[1;44m"
b_magenta="\e[1;45m"
b_cyan="\e[1;46m"
b_white="\e[1;47m"
 
# Non color settings
reset="\e[0m"
# }}}

# Begin main tasks {{{
for i in {1..5}; do
  numone=$("${HOME}"/scripts/pwgen.sh 1-6 5 5)
  numtwo=$("${HOME}"/scripts/pwgen.sh 1-6 5 5)
  wordone=$(grep "${numone}" "${HOME}"/Documents/DiceWare_Wordlist.txt | awk -F' ' '{ print $2 }')
  wordtwo=$(grep "${numtwo}" "${HOME}"/Documents/DiceWare_Wordlist.txt | awk -F' ' '{ print $2 }')
  echo -e "${f_green} Suggested words pairs are ${reset}${f_red} ${wordone} ${reset} ${f_green}and${reset} ${f_red} ${wordtwo} ${reset}"
done;
# }}}

exit 0
