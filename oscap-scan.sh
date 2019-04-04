#!/usr/bin/bash
# Purpose: Run an oscap scan with the rhel7 disa stig
# Date: 20180220
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
resultfile="${HOME}/$(date +%F)-xccdf.xml"
reportfile="${HOME}/$(date +%F)-xccdf.html"
# }}}

# Misc function definitions {{{

check_root() { #{{{ String comparison
if [[ $EUID -ne 0 ]]; then
  echo -e "You need to be use sudo or be root to run this script"
  echo -e "For example: sudo ./$(basename ${0})"
  exit 1
 fi
} #}}}

# }}}

# Begin main tasks {{{
check_root
oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_stig-rhel7-disa --results "${resultfile}" --report "${reportfile}" /usr/share/xml/scap/ssg/content/ssg-rhel7-ds.xml

# }}}

exit 0
