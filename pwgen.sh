#! /bin/bash
 
### pwgen.sh --- Generate a random password with /dev/urandom
 
## Copyright (C) 2008  Aaron S. Hawley <aaronh@localhost>
 
## Author: Aaron S. Hawley
## Keywords: random, unix, sysadmin
 
## This program is free software: you can redistribute it and/or
## modify it under the terms of the GNU General Public License as
## published by the Free Software Foundation, either version 3 of
## the License, or (at your option) any later version.
 
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
 
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.
 
## $Id: pwgen.sh,v 1.1 2008/06/19 14:47:36 aaronh Exp $
 
### Commentary:
 
## This shell script will generate a random password using a character
## set expressed for the tr(1) command, and of the length between MIN
## and MAX.
 
### Usage:
 
## $ pwgen CHARSET MIN MAX
 
### Examples:
 
## $ pwgen [:alnum:] 0 8
## 0TfjQe
 
## If you don't have a fully POSIX-compliant version of tr(1), you can
## use
 
## $ pwgen a-zA-Z0-9 8 16
## s7RCVcOLCc
 
## If you need a random personal identification number for your
## account on a automated bank teller machine:
 
## $ pwgen 0-9 4 4
## 5120
 
## Note that the script does not enforce any requirements about the
## result -- for example, the existence of certain types of
## characters.
 
## That can easily be enforced, however by just generating a password
## that satisfies your requirements.  Here's how to use grep(1) to
## require at least one uppercase, one number and one punctuation
## character.
 
## $ while ( ! pwgen [:alnum:][:punct:] 2 4 \
##           | grep -e [A-Z] | grep -e [0-9] \
##           | grep -e [[:punct:]] ); do :; done
## ,8jP
 
### Code:
 
if [ -z "$1" -o -z "$2" -o -z "$3" ]; then
    echo >&2 "Usage: $0 CHARSET MIN MAX"
    exit 1;
fi
 
char_set="$1"
shift;
 
if !(echo | tr -d "${char_set}" > /dev/null 2> /dev/null ); then
    echo >&2 "Invalid character set: ${char_set}";
    exit 1;
fi
 
min_length="$1"
shift;
 
if [ ! "${min_length}" -ge 0 ]; then
    echo >&2 "Minimum length must be greater than 0: ${min_length}"
    exit 1;
fi
 
max_length="$1"
shift;
 
if [ ! "${max_length}" -ge "${min_length}" ]; then
    echo >&2 "Maximum length can't be less than minimum length: ${max_length}"
    exit 1;
fi
 
modulo=$(( $max_length - $min_length))
 
RANDOM=$$;
 
rand_length=$( echo $(( $RANDOM % ( $modulo + 1 ) + $min_length )) )
 
if [ "${rand_length}" -gt "${max_length}" \
     -o "${rand_length}" -lt "${min_length}" ]; then
    echo >&2 "Oops!  Password length not between ${min_length} and ${max_length}";
fi
 
## Zero-length passwords known to be insecure.
if [ "${rand_length}" == 0 ]; then
    echo "";
fi
 
password="$( tr -dc "${char_set}" < /dev/urandom | head -c "${rand_length}" )";
 
echo "${password}"
 
## end pwgen.sh
