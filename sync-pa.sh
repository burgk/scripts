#!/usr/bin/bash
# Sync Portable Apps Document directory with my Google Drive
# Portable is at d: and Google is at g:

# Misc variable definitions {{{
padir="/cygdrive/d/Documents/"
gddir="/cygdrive/g/My\ Drive/P.A.com-Docs"
# }}} End misc var

# Begin main tasks {{{
if [[ -e "${padir}" ]] && [[ -e "${gddir}" ]]; then
  echo -e "Both dirs are available, initiating sync.."
  rsync -havz "${padir}" "${gddir}"
else
  echo -e "One of the paths is missing, exiting!"
  exit 1
fi

# End main tasks }}}
