#!/usr/bin/env bash
# Purpose: printf building practice
# Date: 2019-05-01
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{

# }}}
surname="Burg"
firstname="Kevin"
the_mac="08:00:27:41:23:b4"

# Begin main tasks {{{

# }}}
printf "%12s: %4d\n" "string 1" 12 "string 2" 122
printf "%s\n" "-----"

printf "%-12s: %-4d\n" "string 1" 12 "string 2" 122
printf "%s\n" "-----"

printf "%-12s: %4d\n" "string 1" 12 "string 2" 12222
printf "%s\n" "-----"

printf "%-15s %-15s\n" "CDA" "Legislature"
printf "%-15s %-15s\n" "CDPHE" "OIT"
printf "%-15s %-15s\n" "CDOT" "State Capitol"
printf "%s\n" "-----"

printf -v var1 "Hello World"
echo "$var1"
printf "%s\n" "-----"

printf "Surname: %s\nName: %s\n" "$surname" "$firstname"
printf "%s\n" "-----"

echo "$the_mac"
the_mac="$(printf "%02x:%02x:%02x:%02x:%02x:%02x" 0x${the_mac//:/ 0x})"
echo "$the_mac"
the_mac="$(printf "%02X:%02X:%02X:%02X:%02X:%02X" 0x${the_mac//:/ 0x})"
echo "$the_mac"
printf "%s\n" "-----"

for (( x=0; x <=15; x++ )); do
  printf '%3d | %04o | 0x%02x\n' "$x" "$x" "$x"
done


divider===============================
divider=$divider$divider

header="\n %-10s %8s %10s %11s\n"
format=" %-10s %08d %10s %11.2f\n"

width=43

printf "$header" "ITEM NAME" "ITEM ID" "COLOR" "PRICE"

printf "%$width.${width}s\n" "$divider"

printf "$format" \
Triangle 13  red 20 \
Oval 204449 "dark blue" 65.656 \
Square 3145 orange .7

user_suser="burgk"
#user_ad="STATECAPITOL.COLORADO.LCL"
user_ad="DOT.STATE.CO.US"
f_red="\e[31m"
f_green="\e[32m"
f_yellow="\e[33m"
reset="\e[0m"
echo -e "\n${f_red}"
printf "%56s\n" "-->  ----------------------------------------------  <--"
printf "%-50s %5s\n" "-->  ERROR: User: ${user_suser}  " "<--"
printf "%-50s %5s\n" "-->  Not found in: ${user_ad}  " "<--"
printf "%-50s %5s\n" "-->  Please re-enter  " "<--"
printf "%56s\n" "-->  ----------------------------------------------  <--"
echo -e "${reset}\n"

echo -e "${f_yellow}--> Building Access Zone list for cluster..${reset}"
echo -e "${f_yellow}--> Getting AD providers for Access Zones..${reset}"
echo -e "${f_yellow}--> Finding online AD providers..${reset}"
echo -e "\n"
printf "%-50b %5b\n" "${f_yellow}-->  Building Access Zone list for cluster.. " "<--${reset}"
printf "%-50b %5b\n" "${f_yellow}-->  Getting AD providers for Access Zones.. " "<--${reset}"
printf "%-50b %5b\n" "${f_yellow}-->  Finding online AD providers..  " "<--${reset}"

# echo -e "${f_yellow}--> Collecting logs from node ${count} of ${realnodecount}.. <--${reset}"
# echo -e "${f_yellow}-->  Log contained ${reset}${f_red}${rec_count_1}${reset}${f_yellow} relevant records, removing.. <--${reset}"
# echo -e "${f_yellow}-->  Log contains ${reset}${f_green}${rec_count_1}${reset}${f_yellow} filtered records <--${reset}"
# echo -e "${f_yellow}--> Pulling relevant fields from ${loglist[$i]%.*}.. <--${reset}"
# echo -e "${f_yellow}-->  Log contains ${reset}${f_green}${rec_count_2}${reset}${f_yellow} records <--${reset}"
# echo -e "${f_yellow}--> Pulling delete events from ${loglist[$i]%.*}.. <--${reset}"
# echo -e "${f_yellow}-->  No delete events found, removing.. <--${reset}"
# echo -e "${f_yellow}-->  Log contains ${reset}${f_green}${rec_count_2}${reset}${f_yellow} delete records <--${reset}"
# echo -e "${f_yellow}--> Formatting fields from ${audres_list[$i]%.*}.. <--${reset}"
# echo -e "${f_yellow}-->  Log contains ${reset}${f_green}${rec_count_3}${reset}${f_yellow} records <--${reset}"

echo -e "\n${f_yellow}--> Building SID list.. <--${reset}"
# echo -e "${f_yellow}--> Resolving SID ${count} of ${sidcount}.. <--${reset}"
echo -e "\n${f_yellow}--> Updating records with UserID.. <--${reset}"

# echo -e "${f_yellow}--> Log contains ${reset}${f_green}${rec_count_3}${reset}${f_yellow} formatted records including new header <--${reset}"

echo -e "${f_red}--> User aborted - Cleaning up <--"
echo -e "--> Done - Goodbye <--\n${reset}"

echo -e "${f_yellow}--> Cleaning up <--"
echo -e "--> Done - Goodbye <--\n${reset}"

echo -e "\n${f_green}--> User entries have been confirmed, continuing.. <--${reset}"

exit 0
