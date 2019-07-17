#!/usr/bin/env bash
# Purpose: 
# Date:
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
# set -x # Enable debug
st_path="$HOME"/Audit/test
log="fakelog.txt"
# }}}

# Function definitions {{{
test_sed(){
read -rep "Enter user to search: " user_suser
cd "${st_path}" || exit
touch "${user_suser}"
echo -e "\nhere is our file:"
ls "${st_path}"
echo -e "\nResolving sid..."
user_sid="S-1-5-21-98-202442-20885976-1108"
mv ./"${user_suser}" ./"${user_suser}_${user_sid}"
echo -e "\nour files now:"
ls "${st_path}"
echo -e "\ncurrent file contents:"
cat "${log}"
echo -e "\nrunning sed on it..."
sed -nE "s/${user_sid}/${user_suser}/gp"
echo -e "\nfile now:"
cat "${log}"
}
# }}}

# Begin main tasks {{{
test_sed
# }}}

exit 0
