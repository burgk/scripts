#!/usr/bin/env bash

# Utility to start, stop or query the status of some McAfee services
# It tries to be reasonably careful, but there are no guarantees :-)
# May add a kill/unkill option to disable/ enable the service
# Use sc qc to get config state

if [ $# -ne 1 ]
then
  echo "Usage: mcafee.sh start, status or stop."
  exit 1
fi

MHIPSSTATE=`sc query enterceptAgent | grep STATE | awk '{ print $4 }'`

if [ $1 = status ]
then
  echo "McAfee Host Intrusion Prevention Service status: ${MHIPSSTATE}"
  exit 0
  
elif [ $1 = start ]
then
  if [ "${MHIPSSTATE}" = "RUNNING" ]
  then
    echo "McAfee Host Intrusion Prevention Service is already running..."
  else
    echo "Starting McAfee Host Intrusion Prevention Service ..."
    MHIPSTMP=`sc start enterceptAgent | grep STATE | awk '{ print $4 }'`
    echo "McAfee Host Intrusion Prevention Service status: ${MHIPSTMP}"
    sleep 3
    MHIPSTMP=`sc query enterceptAgent | grep STATE | awk '{ print $4 }'`
    echo "McAfee Host Intrusion Prevention Service status: ${MHIPSTMP}"
  fi
  exit 0
  
elif [ $1 = stop ]
then
  if [ "${MHIPSSTATE}" = "STOPPED" ]
  then
    echo "McAfee Host Intrusion Prevention Service is already stopped..."
  else
    echo "Stopping McAfee Host Intrusion Prevention Service ..."
    MHIPSTMP=`sc stop enterceptAgent | grep STATE | awk '{ print $4 }'`
    echo "McAfee Host Intrusion Prevention Service status: ${MHIPSTMP}"
    sleep 3
    MHIPSTMP=`sc query enterceptAgent | grep STATE | awk '{ print $4 }'`
    echo "McAfee Host Intrusion Prevention Service status: ${MHIPSTMP}"
  fi
  exit 0
  
else
  echo "Usage: mcafee.sh start, status or stop."
  exit 1
  
fi
exit 0




