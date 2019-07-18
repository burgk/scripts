#!/usr/bin/bash
# Sync Portable Apps Document directory with my Google Drive
# Portable is at d: and Google is at g:

# Misc variable definitions {{{
padir="/cygdrive/d/Documents/"
paready="false"
gddir='/cygdrive/g/My Drive/P.A.com-Docs'
gdready="false"
# }}} End misc var

# Begin main tasks {{{
if [[ -e "${padir}" ]]; then
  echo -e "PortableApps dir available - good"
  paready="true"
else
  echo -e "PortableApps dir not available - exiting!"
  exit 1
fi

if [[ -e "${gddir}" ]]; then
  echo -e "Google Drive dir available - good"
  gdready="true"
else
  echo -e "Google Drive not available - exiting!"
  exit 1
fi

if [[ "${paready}" == "true" ]] && [[ "${gdready}" == "true" ]]; then
  echo -e "Both sync paths available - continuing.."
  rsync -havz "${padir}" "${gddir}"
fi
exit 0
# End main tasks }}}
