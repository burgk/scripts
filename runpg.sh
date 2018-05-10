#!/bin/bash
 
# runpg.sh - wrapper to run password generator script with some entries set
# other option include:
# alnum, alpha, blank, cntrl, digit, graph, print, space, xdigit
# see man tr for details
 
PWGEN=/home/burgk/scripts/pwgen.sh

echo -e "4 digit pin:"
${PWGEN} [:digit:] 4 4
echo -e "5 digits for wordlist use:"
${PWGEN} 1-6 5 5
echo -e "6 character password:"
${PWGEN} [:lower:][:upper:][:punct:][:digit:] 6 6
echo -e "8 character password:"
${PWGEN} [:lower:][:upper:][:punct:][:digit:] 8 8
echo -e "10 character password:"
${PWGEN} [:lower:][:upper:][:punct:][:digit:] 10 10
echo -e "12 character password:"
${PWGEN} [:lower:][:upper:][:punct:][:digit:] 12 12
echo -e "48 character password:"
${PWGEN} [:lower:][:upper:][:punct:][:digit:] 48 48
echo -e "64 character password:"
${PWGEN} [:lower:][:upper:][:punct:][:digit:] 64 64
exit 0
