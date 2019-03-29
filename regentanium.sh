#!/bin/bash
# Purpose: Rebuild Tanium Client package
# Date: 20190225
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
builddir="${HOME}/Tanium"
installer="${HOME}/scripts/installtanium.sh"
installersum=$(sha1sum "${installer}" | awk '{print $1}')
readme="${HOME}/Tanium/README.txt"
readmesum=$(sha1sum "${readme}" | awk '{print $1}')
# }}}

rebuild_package() { #{{{
cd "${builddir}" || exit

if [[ -e "./TaniumClient${distro}.tar.gz" ]]; then
  echo -e "Found existing tarball, moving..."
  mv "./TaniumClient${distro}.tar.gz" "./TaniumClient${distro}.tar.$(date +%s).gz"
fi

if [[ -e "./TaniumClient${distro}/InstallTanium${distro}.sh" ]]; then
  distrosum=$(sha1sum ./TaniumClient"${distro}"/InstallTanium"${distro}".sh | awk '{print $1}')
  echo -e "Found existing installer, checksum created"
else
  echo -e "No installer found, adding it"
  cp "${installer}" "./TaniumClient${distro}/InstallTanium${distro}.sh"
fi

if [[ -e "./TaniumClient${distro}/README.txt" ]]; then
  distroreadmesum=$(sha1sum ./TaniumClient"${distro}"/README.txt | awk '{print $1}')
  echo -e "Found existing readme file, checksum created"
else
  echo -e "No existing readme file, adding it"
  cp "${readme}" "./TaniumClient${distro}/README.txt"
fi

if [[ "${installersum}" != "${distrosum}" ]]; then
  echo -e "Installer checksum mismatch, installing new version of installer"
  chmod 755 "./TaniumClient${distro}/InstallTanium${distro}.sh"
  cp "${installer}" "./TaniumClient${distro}/InstallTanium${distro}.sh"
  chmod 555 "./TaniumClient${distro}/InstallTanium${distro}.sh"
else
  echo -e "Installer checksums match, continuing"
fi

if [[ "${readmesum}" != "${distroreadmesum}" ]]; then
  echo -e "Readme checksum mismatch, installing new version of readme"
  chmod 644 "./TaniumClient${distro}/README.txt"
  cp "${readme}" "./TaniumClient${distro}/README.txt"
  chmod 444 "./TaniumClient${distro}/README.txt"
else
  echo -e "Readme checksums match, continuing"
fi

echo -e "Creating new tarball.."
tar cvfa ./TaniumClient"${distro}".tar.gz ./TaniumClient"${distro}"
} #}}}

# Begin main tasks {{{
echo -e "Available rebuild options are:"
echo -e "All \t\t AWS"
echo -e "Debian \t\t Oracle"
echo -e "RHEL \t\t SUSE"
echo -e "Ubuntu"
echo -n "Package to rebuild (you probably want All): "
read -r response
case ${response} in
  All | all)
  declare -a all_distros=("AWS" "Debian" "Oracle" "SUSE" "RHEL" "Ubuntu")
  for distro in "${all_distros[@]}"; do
    rebuild_package "${distro}"
  done
  ;;
  AWS | aws)
  distro="AWS"
  rebuild_package "${response}"
  ;;
  Debian | debian)
  distro="Debian"
  rebuild_package "${response}"
  ;;
  Oracle | oracle)
  distro="Oracle"
  rebuild_package "${response}"
  ;;
  SUSE | suse)
  distro="SUSE"
  rebuild_package "${response}"
  ;;
  RHEL | rhel)
  distro="RHEL"
  rebuild_package "${response}"
  ;;
  Ubuntu | ubuntu)
  distro="Ubuntu"
  rebuild_package "${response}"
  ;;
  *)
  echo -e "Does -> ${response} <- look like one of those options??"
  echo -e "Invalid entry, exiting"
  exit 1
  ;;
esac
# }}}

exit 0
