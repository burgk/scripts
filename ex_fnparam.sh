#!/usr/bin/env bash
# Purpose: 
# Date:
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
# set -x # Enable debug

# }}}

# Function definitions {{{
test_fcn(){ # {{{
echo -e "First argument passed to function: ${1}"
echo -e "Second argument passed to function: ${2}"
echo -e "All arguments passed to function: " "${@}"
echo -e "Number of arguments passed to function: ${#}"
} # }}}

# Begin main tasks {{{
echo -e "pass 1: all delete"
test_fcn all delete
echo -e "pass 2: all"
test_fcn all
echo -e "pass 3: delete"
test_fcn delete
# }}}

exit 0
