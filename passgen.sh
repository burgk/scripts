#!/bin/bash
 
# runpg.sh - wrapper to run password generator script with some entries set
# other option include:
# alnum, alpha, blank, cntrl, digit, graph, print, space, xdigit
# see man tr for details

# Set 8 bit foreground colors
F_BLACK="\e[1;30m"
F_RED="\e[1;31m"
F_GREEN="\e[1;32m"
F_YELLOW="\e[1;33m"
F_BLUE="\e[1;34m"
F_MAGENTA="\e[1;35m"
F_CYAN="\e[1;36m"
F_WHITE="\e[1;37m"

# Set 8 bit background colors
B_BLACK="\e[1;40m"
B_RED="\e[1;41m"
B_GREEN="\e[1;42m"
B_YELLOW="\e[1;43m"
B_BLUE="\e[1;44m"
B_MAGENTA="\e[1;45m"
B_CYAN="\e[1;46m"
B_WHITE="\e[1;47m"
 
# Non color settings
RESET="\e[0m"

for i in {1..5}
do
NUMONE=$(${HOME}/scripts/pwgen.sh 1-6 5 5)
NUMTWO=$(${HOME}/scripts/pwgen.sh 1-6 5 5)
WORDONE=$(grep $NUMONE ${HOME}/Documents/DiceWare_Wordlist.txt | awk -F' ' '{ print $2 }')
WORDTWO=$(grep $NUMTWO ${HOME}/Documents/DiceWare_Wordlist.txt | awk -F' ' '{ print $2 }')

echo -e "${F_GREEN} Suggested words pairs are ${RESET}${F_RED} ${WORDONE} ${RESET} ${F_GREEN}and${RESET} ${F_RED} ${WORDTWO} ${RESET}"
done;

exit 0
