#!/usr/bin/env bash
# Purpose: Time how long a script takes to run
# Date: 20170824
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
runcmd="/usr/bin/du"
destdir="${1}"
# }}}

# Begin main tasks {{{
starttime=$(date +"%s")
"${runcmd}" --summarize --human-readable "${destdir}"
endtime=$(date +"%s")
runtime=$(date -u -d "0 ${endtime} sec - ${starttime} sec" +"%H:%M:%S")
echo -e "Runtime was ${runtime}"
# }}}
