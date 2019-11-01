#!/usr/bin/bash

releasesURL=https://github.com/VSCodium/vscodium/releases
latestURL=$(curl -fsSLI -o /dev/null -w "%{url_effective}" $releasesURL/latest)
latestVer=${latestURL##*/}
codeVersion=$(codium -v)

trap "exit" INT
if [ "$(printf "%s" "$codeVersion" | head -n 1)" != "$latestVer" ]
then
  tempDir=$(mktemp -d)
  pushd "$tempDir" || exit
    releaseName=VSCodiumSetup-$(printf "%s" "$codeVersion" | sed "3q;d")-$latestVer.exe
    awk -v releasesURL="$releasesURL" -v latestVer="$latestVer" -v releaseName="$releaseName" '
     BEGIN {
       a[0] = ""
       a[1] = ".sha256"
       for (i in a) {
           print releasesURL "/download/" latestVer "/" releaseName a[i] | "xargs wget"
       }
     }
 '
      sha256sum -c "$releaseName.sha256" && start "$releaseName"
  popd || exit
fi
