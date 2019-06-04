#!/usr/bin/env bash
# Purpose: 
# Date:
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
# set -x # Enable debug
ts=$(date +%s)
iaopath="/ifs/iao-${ts}"
testpath="/ifs/iao-1559664432"
# }}}

# Function definitions {{{
parse_log(){ # {{{ Pull out relevant parts of audit record for formatting
echo -e "\n********************************"
echo -e "**  LOG PARSING - FORMATTING  **"
echo -e "********************************"
declare -a loglist
cd "${testpath}" || exit
loglist=( *.gz )
echo -e "${loglist[@]}"
} # }}} End parse_log

# }}}

# Begin main tasks {{{
parse_log

# }}}

exit 0
