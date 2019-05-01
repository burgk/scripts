#!/usr/bin/env bash
# Purpose: printf builting practice
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

exit 0
