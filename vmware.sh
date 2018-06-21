#!/usr/bin/env bash
# Kevin Burg - burg.kevin@gmail.com 
# Utility to start, stop or query VMware Service status
# It tries to be reasonably careful, but there are no guarantees :-)
 
if [ $# -ne 1 ]
then
  echo "Usage: vmware.sh start, stop or status."
  exit 1
fi
 
VMNETDHCPSTATE=`sc query VMnetDHCP | grep STATE | awk '{ print $4 }'`
VMNATSTATE=`sc query VMware\ NAT\ Service | grep STATE | awk '{ print $4 }'`
VMAUTHDSTATE=`sc query VMAuthdService | grep STATE | awk '{ print $4 }'`
VMUSBARBSTATE=`sc query VMUSBArbService | grep STATE | awk '{ print $4 }'`
VMWORKSTATIONSTATE=`sc query VMwareHostd | grep STATE | awk '{ print $4 }'`
 
if [ $1 = status ]
then
  echo "VMware DHCP Service status: ${VMNETDHCPSTATE}"
  echo "VMware NAT Service status: ${VMNATSTATE}"
  echo "VMware Authorization Service status: ${VMAUTHDSTATE}"
  echo "VMware USB Arbitration Service status: ${VMUSBARBSTATE}"
  echo "VMware Workstation Service status: ${VMWORKSTATIONSTATE}"
  exit 0
   
elif [ $1 = start ]
then
  if [ "${VMNETDHCPSTATE}" = "RUNNING" ]
  then
    echo "VMware DHCP Service is already running..."
  else
    echo "Starting VMware DHCP Service..."
    DHCPTMP=`sc start VMnetDHCP | grep STATE | awk '{ print $4 }'`
    echo "VMware DHCP Service state: ${DHCPTMP}"
    sleep 2
    DHCPTMP=`sc query VMnetDHCP | grep STATE | awk '{ print $4 }'`
    echo "VMware DHCP Service state: ${DHCPTMP}"
  fi
   
  if [ "${VMNATSTATE}" = "RUNNING" ]
  then
    echo "VMware NAT Service is already running..."
  else
    echo "Starting VMware NAT Service..."
    NATTMP=`sc start VMware\ NAT\ Service | grep STATE | awk '{ print $4 }'`
    echo "VMware NAT Service state: ${NATTMP}"
    sleep 2
    NATTMP=`sc query VMware\ NAT\ Service | grep STATE | awk '{ print $4 }'`
    echo "VMware NAT Service state: ${NATTMP}"
  fi
   
  if [ "${VMAUTHDSTATE}" = "RUNNING" ]
  then
    echo "VMware Authorization Service is already running..."
  else
    echo "Starting VMware Authorization Service..."
    AUTHTMP=`sc start VMAuthdService | grep STATE | awk '{ print $4 }'`
    echo "VMware Authorization Service state: ${AUTHTMP}"
    sleep 2
    AUTHTMP=`sc query VMAuthdService | grep STATE | awk '{ print $4 }'`
    echo "VMware Authorization Service state: ${AUTHTMP}"
  fi
   
  if [ "${VMUSBARBSTATE}" = "RUNNING" ]
  then
    echo "VMware USB Arbitration Service is already running..."
  else
    echo "Starting VMware USB Arbitration Service..."
    USBARBTMP=`sc start VMUSBArbService | grep STATE | awk '{ print $4 }'`
    echo "VMware USB Arbitration Service state: ${USBARBTMP}"
    sleep 2
    USBARBTMP=`sc query VMUSBArbService | grep STATE | awk '{ print $4 }'`
    echo "VMware USB Arbitration Service state: ${USBARBTMP}"
  fi
   
  if [ "${VMWORKSTATIONSTATE}" = "RUNNING" ]
  then
    echo "VMware Workstation Service is already running..."
  else
    echo "Starting VMware Workstation Service..."
    WORKTMP=`sc start VMwareHostd | grep STATE | awk '{ print $4 }'`
    echo "VMware Workstation Service state: ${WORKTMP}"
    sleep 2
    WORKTMP=`sc query VMwareHostd | grep STATE | awk '{ print $4 }'`
    echo "VMware Workstation Service state: ${WORKTMP}"
  fi
  exit 0
   
elif [ $1 = stop ]
then
  if [ "${VMNETDHCPSTATE}" = "STOPPED" ]
  then
    echo "VMware DHCP Service is already stopped..."
  else
    echo "Stopping VMware DHCP Service..."
    DHCPTMP=`sc stop VMnetDHCP | grep STATE | awk '{ print $4 }'`
    echo "VMware DHCP Service state: ${DHCPTMP}"
    sleep 2
    DHCPTMP=`sc query VMnetDHCP | grep STATE | awk '{ print $4 }'`
    echo "VMware DHCP Service state: ${DHCPTMP}"
  fi
   
  if [ "${VMNATSTATE}" = "STOPPED" ]
  then
    echo "VMware NAT Service is already stopped..."
  else
    echo "Stopping VMware NAT Service..."
    NATTMP=`sc stop VMware\ NAT\ Service | grep STATE | awk '{ print $4 }'`
    echo "VMware NAT Service state: ${NATTMP}"
    sleep 2
    NATTMP=`sc query VMware\ NAT\ Service | grep STATE | awk '{ print $4 }'`
    echo "VMware NAT Service state: ${NATTMP}"
  fi
   
  if [ "${VMWORKSTATIONSTATE}" = "STOPPED" ]
  then
    echo "VMware Workstation Service is already stopped..."
  else
    echo "Stopping VMware Workstation Service..."
    WORKTMP=`sc stop VMwareHostd | grep STATE | awk '{ print $4 }'`
    echo "VMware Workstation Service state: ${WORKTMP}"
    sleep 2
    WORKTMP=`sc query VMwareHostd | grep STATE | awk '{ print $4 }'`
    echo "VMware Workstation Service state: ${WORKTMP}"
  fi
   
  if [ "${VMAUTHDSTATE}" = "STOPPED" ]
  then
    echo "VMware Authorization Service is already stopped..."
  else
    echo "Stopping VMware Authorization Service..."
    AUTHTMP=`sc stop VMAuthdService | grep STATE | awk '{ print $4 }'`
    echo "VMware Authorization Service state: ${AUTHTMP}"
    sleep 2
    AUTHTMP=`sc query VMAuthdService | grep STATE | awk '{ print $4 }'`
    echo "VMware Authorization Service state: ${AUTHTMP}"
  fi
   
  if [ "${VMUSBARBSTATE}" = "STOPPED" ]
  then
    echo "VMware USB Arbitration Service is already stopped..."
  else
    echo "Stopping VMware USB Arbitration Service..."
    USBARBTMP=`sc stop VMUSBArbService | grep STATE | awk '{ print $4 }'`
    echo "VMware USB Arbitration Service state: ${USBARBTMP}"
    sleep 2
    USBARBTMP=`sc query VMUSBArbService | grep STATE | awk '{ print $4 }'`
    echo "VMware USB Arbitration Service state: ${USBARBTMP}"
  fi
  exit 0
else
  echo "Usage: vmware.sh start, stop or status"
  exit 1
fi
exit 0
