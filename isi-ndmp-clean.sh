#!/usr/bin/env bash
# Script to run the ndmp snapshot cleanup script on EF and LW X400 Isilons
# Kevin Burg - kevin.burg@state.co.us - 303.941.3472

# Needed this to get access to cached ssh key
eval $(keychain --noask --eval id_rsa)

echo -e "************************************"
echo -e "Starting cleanup script on EFX400..."
echo -e "************************************"
ssh root@10.35.11.220 /tmp/ndmp-snap-cleanup.sh

echo -e "*** Done on EFX400, waiting to start LWX400 ***"
sleep 120

echo -e "************************************"
echo -e "Starting cleanup script on LWX400..."
echo -e "************************************"
ssh root@10.35.11.220 /tmp/lwx400-clean.sh

exit 0
