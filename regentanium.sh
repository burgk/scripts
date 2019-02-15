#!/bin/bash
# Rebuild Tanium Client package

builddir="${HOME}/Tanium"
installer="${HOME}/scripts/installtanium.sh"
installersum=$(sha1sum "${installer}" | awk '{print $1}')
readme="${HOME}/Tanium/README.txt"
readmesum=$(sha1sum "${readme}" | awk '{print $1}')

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
  echo -e "Checksum mismatch, installing new version of installer"
  chmod 755 "./TaniumClient${distro}/InstallTanium${distro}.sh"
  cp "${installer}" "./TaniumClient${distro}/InstallTanium${distro}.sh"
  chmod 555 "./TaniumClient${distro}/InstallTanium${distro}.sh"
else
  echo -e "Installer checksums match, continuing"
fi

if [[ "${readmesum}" != "${distroreadmesum}" ]]; then
  echo -e "Checksum mismatch, installing new version of readme"
  chmod 644 "./TaniumClient${distro}/README.txt"
  cp "${readme}" "./TaniumClient${distro}/README.txt"
  chmod 444 "./TaniumClient${distro}/README.txt"
else
  echo -e "Readme checksums match, continuing"
fi

echo -e "Creating new tarball.."
tar cvfa ./TaniumClient"${distro}".tar.gz ./TaniumClient"${distro}"
} #}}}

echo -e "Available rebuild options are:"
echo -e "All \t\t AWS"
echo -e "Debian \t\t Oracle"
echo -e "RHEL \t\t SUSE"
echo -e "Ubuntu"
echo -n "Package to rebuild: "
read -r response
case ${response} in
  All)
  declare -a all_distros=("AWS" "Debian" "Oracle" "SUSE" "RHEL" "Ubuntu")
  for distro in "${all_distros[@]}"; do
    rebuild_package "${distro}"
  done
  ;;
  AWS)
  distro="AWS"
  rebuild_package "${response}"
  ;;
  Debian)
  distro="Debian"
  rebuild_package "${response}"
  ;;
  Oracle)
  distro="Oracle"
  rebuild_package "${response}"
  ;;
  SUSE)
  distro="SUSE"
  rebuild_package "${response}"
  ;;
  RHEL)
  distro="RHEL"
  rebuild_package "${response}"
  ;;
  Ubuntu)
  distro="Ubuntu"
  rebuild_package "${response}"
  ;;
  *)
  echo -e "Invalid entry, exiting"
  exit 1
  ;;
esac
