#!/usr/bin/env bash
# Script to delete all un-locked ndmp-* snapshots
# Kevin Burg - kevin.burg@state.co.us 2017-12-19

DATE=$(date +%F)
touch /tmp/${DATE}-snaplist.txt
touch /tmp/${DATE}-delete-list.txt
touch /tmp/${DATE}-snapinfo.txt
ALLSNAP=/tmp/${DATE}-snaplist.txt
DELSNAP=/tmp/${DATE}-delete-list.txt
SNAPINFO=/tmp/${DATE}-snapinfo.txt

createlist()
{
isi snapshot snapshots list --no-header --no-footer --format=table --sort=path | grep ndmp | awk '{print $1}' >> ${ALLSNAP}
ALLCOUNT=$(wc -l ${ALLSNAP} | awk '{print $1}')
echo -e "-----------------------------------------------------------------"
echo -e "NDMP Cleanup Script run on ${DATE}"
echo -e "Currently ${ALLCOUNT} Commvault generated ndmp-* snaps on cluster"
echo -e "-----------------------------------------------------------------"
}

cleanlist()
{
while read -r SNAP; do
 isi snapshot snapshots view --snapshot=${SNAP} | grep -q "Has Locks: No"
  if [ $? == 0 ]
  then
   echo -e "Adding snapshot with ID ${SNAP} to the delete list"
   echo -e "${SNAP}" >> ${DELSNAP}
  fi
done < ${ALLSNAP}
DELCOUNT=$(wc -l ${DELSNAP} | awk '{print $1}')
echo -e "Added ${DELCOUNT} unlocked snaps to the delete list"
}

documentlist()
{
echo -e "----------------------------------------------------------------"
echo -e "Creating information file of snaps to be deleted, please wait..."
echo -e "----------------------------------------------------------------"
while read -r SNAP; do
 isi snapshot snapshots view --snapshot=${SNAP} >> ${SNAPINFO}
done < ${DELSNAP}
}

processlist()
{
DELCOUNT=$(wc -l ${DELSNAP} | awk '{print $1}')
echo -e "----------------------------------------------------------------"
echo -e "Starting deletion of ${DELCOUNT} snaps from the delete list"
echo -e "----------------------------------------------------------------"
COUNT=1
while read -r DEL; do
 echo -e "Deleting snapshot ${COUNT} of ${DELCOUNT} with snapshot ID ${DEL}"
 isi snapshot snapshots delete --snapshot=${DEL} --force 2>/dev/null
(( COUNT++ ));
done < ${DELSNAP}
}

cleanup()
{
STORPATH=/ifs/home/burgk/ndmp/results
chown 2011:1800 ${ALLSNAP} ${DELSNAP} ${SNAPINFO}
echo -e "--------------------------------------------------------------"
echo -e "Moving working files to compressed tar file in ${STORPATH}"
echo -e "--------------------------------------------------------------"
if [ -e ${STORPATH}/snap-results.tar.bz2 ]
 then
  bunzip2 ${STORPATH}/snap-results.tar.bz2
  tar -uf ${STORPATH}/snap-results.tar ${ALLSNAP} ${DELSNAP} ${SNAPINFO} 2>/dev/null
  bzip2 ${STORPATH}/snap-results.tar
 else
  tar -cf ${STORPATH}/snap-results.tar ${ALLSNAP} ${DELSNAP} ${SNAPINFO} 2>/dev/null
  bzip2 ${STORPATH}/snap-results.tar
fi
rm -f ${ALLSNAP} ${DELSNAP} ${SNAPINFO}
}

createlist
cleanlist
documentlist
processlist
cleanup
exit 0
