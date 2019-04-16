#!/usr/bin/bash
# Purpose: Download CDOT FedACH data
# Date: 20190415
# Kevin Burg - Kevin.Burg@state.co.us

# Misc variable definitions {{{
destdir="/home/burgk/Documents/FedACH"
rundate=$(date +%F-%H%M%S)
resultfile="${destdir}/${rundate}-CDOT-FedACH.txt"
header1="X_FRB_EPAYMENTS_DIRECTORY_ORG_ID: 121000248" 
header2="X_FRB_EPAYMENTS_DIRECTORY_DOWNLOAD_CD: 3f2b553a-b3dc-4a2c-9213-f2b721142bbd"
dl_url="https://frbservices.org/EPaymentsDirectory/directories/fedach?format=text"
# }}}

dl_data() { # {{{ wrap curl in function
curl -H "${header1}" -H "${header2}" "${dl_url}" > "${resultfile}"
} # }}}

# Begin main tasks {{{
if [[ -e "${destdir}" ]]; then
  dl_data
else
  mkdir "${destdir}"
  dl_data
fi
# }}}

exit 0
