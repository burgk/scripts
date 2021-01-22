#!/bin/bash
# Purpose: Rebuild Tanium Client package
# Date: 20190225
# Date: 20210122 - updated for version 7.4
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
newver="7.4.4.1250" # NEEDS UPDATED EACH TIME AGENT VERSION CHANGES!
regendate=$(date +%s)
builddir="${HOME}/Tanium"
installer="${HOME}/scripts/installtanium-7.4.sh" # USING NEW 7.4 VERSION NOW
installersum=$(sha1sum "${installer}" | awk '{print $1}')
readme="${HOME}/Tanium/README.txt"
readmesum=$(sha1sum "${readme}" | awk '{print $1}')
# }}}

rebuild_package() { #{{{
cd "${builddir}" || exit

if [[ -e "./TaniumClient${distro}.tar.gz" ]]; then
  echo -e "For ${distro}: Found existing tarball for, moving..."
  mv "./TaniumClient${distro}.tar.gz" "./TaniumClient${distro}-${regendate}.tar.gz"
fi

if [[ -e "./TaniumClient${distro}/InstallTanium${distro}.sh" ]]; then
  distrosum=$(sha1sum ./TaniumClient"${distro}"/InstallTanium"${distro}".sh | awk '{print $1}')
  echo -e "For ${distro}: Found existing installer, checksum created"
else
  echo -e "For ${distro}: No installer found, adding it"
  cp "${installer}" "./TaniumClient${distro}/InstallTanium${distro}.sh"
fi

if [[ -e "./TaniumClient${distro}/README.txt" ]]; then
  distroreadmesum=$(sha1sum ./TaniumClient"${distro}"/README.txt | awk '{print $1}')
  echo -e "For ${distro}: Found existing readme file, checksum created"
else
  echo -e "For ${distro}: No existing readme file, adding it"
  cp "${readme}" "./TaniumClient${distro}/README.txt"
fi

if [[ "${installersum}" != "${distrosum}" ]]; then
  echo -e "For ${distro}: Installer checksum mismatch, installing new version of installer"
  chmod 755 "./TaniumClient${distro}/InstallTanium${distro}.sh"
  cp "${installer}" "./TaniumClient${distro}/InstallTanium${distro}.sh"
  chmod 555 "./TaniumClient${distro}/InstallTanium${distro}.sh"
else
  echo -e "For ${distro}: Installer checksums match, continuing"
fi

if [[ "${readmesum}" != "${distroreadmesum}" ]]; then
  echo -e "For ${distro}: Readme checksum mismatch, installing new version of readme"
  chmod 644 "./TaniumClient${distro}/README.txt"
  cp "${readme}" "./TaniumClient${distro}/README.txt"
  chmod 444 "./TaniumClient${distro}/README.txt"
else
  echo -e "For ${distro}: Readme checksums match, continuing"
fi

echo -e "For ${distro}: Creating new tarball" 
tar cfa ./TaniumClient"${distro}-${newver}".tar.gz ./TaniumClient"${distro}"
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
