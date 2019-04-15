#!/usr/bin/bash
# Purpose: Download CDOT FedACH doc
# Date: 20190415
# Kevin Burg - Kevin.Burg@state.co.us

# Misc variable definitions {{{
rundate=$(date +%F-%T)
destdir="/home/burgk/Documents/FedACH"
resultfile="${destdir}/${rundate}-CDOT-FedACH.txt"
# }}}

dl-data() { # {{{ wrap curl in function
curl \
--header "X_FRB_EPAYMENTS_DIRECTORY_ORG_ID: 121000248" \
--header "X_FRB_EPAYMENTS_DIRECTORY_DOWNLOAD_CD: 3f2b553a-b3dc-4a2c-9213-f2b721142bbd" \
https://frbservices.org/EPaymentsDirectory/directories/fedach?format=text > "${resultfile}"
} # }}}

# Begin main tasks {{{
if [[ -e "${destdir}" ]]; then
  dl-data
else
  mkdir "${destdir}"
  dl-data
fi
# }}}

exit 0
