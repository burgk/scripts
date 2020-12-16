#!/usr/bin/env bash
# Use </path>/bash -x to enable tracing of script execution
# Or alternatively set -x to turn on tracing, set +x to turn off
# Script to set ip address vi cli
# Can set ip + subnet or ip + subnet + gateway
# Multiple options allow for a variety of configurations

MINOPT=2
MAXOPT=3
LAN="Local Area Connection"

if [ "$1" = "dhcp" ]
then
  echo "Setting IP via DHCP"
  netsh interface ipv4 set address name="$LAN" source=dhcp
  echo "Setting DNS via DHCP"
  netsh interface ipv4 set dnsservers name="$LAN" source=dhcp
  exit 0
elif [ "$1" = "service" ]
then
  echo "Setting IP for CX/VNX Service LAN connection"
  echo "IP is 128.221.1.249, connect to 128.221.1.250/251"
  netsh interface ipv4 set address name="$LAN" source=static addr=128.221.1.249 mask=255.255.255.248
  exit 0
elif [ "$1" = "switch" ]
then
  echo "Setting IP for Centera Cube Switch connection on the 10.255 network"
  echo "IP is 10.255.1.59, recommended connection is 10.255.1.4"
  echo "If it fails to connect, check which address Centera was initialized with."
  echo "Alternatives are 172.19.1.x and 128.221.1.x"
  netsh interface ipv4 set address name="$LAN" source=static addr=10.255.1.59 mask=255.255.255.192
  exit 0
elif [ "$1" = "node" ]
then
  echo "Setting IP for Centera Node connection"
  echo "IP is 10.255.0.2, connect to 10.255.0.1"
  netsh interface ipv4 set address name="$LAN" source=static addr=10.255.0.2 mask=255.255.255.252
  exit 0
elif [ "$1" = "xio" ]
then
  echo "Setting IP for XIO SC connection"
  echo "IP is 169.254.254.2, connect to 169.254.254.1"
  netsh interface ipv4 set address name="$LAN" source=static addr=169.254.254.2 mask=255.255.240.0
  exit 0
elif [ "$1" = "vplex" ]
then
  echo "Setting IP for VPlex connection"
  echo "IP is 128.221.252.3, connect to 128.221.252.2"
  netsh interface ipv4 set address name="$LAN" source=static addr=128.221.252.3 mask=255.255.255.224 gateway=128.221.252.2
  exit 0
elif [ "$1" = "avamar" ]
then
  echo "Setting IP for Avamar connection"
  echo "IP is 10.99.99.99, connect to eth7 (NIC8) at address 10.99.99.5"
  netsh interface ipv4 set address name="$LAN" source=static addr=10.99.99.99 mask=255.255.255.0 gateway=10.99.99.5
  exit 0
elif [ $# -lt "$MINOPT" ]
then
  echo "Please enter IP and CIDR formatted subnet mask (20 through 30), gateway is optional."
  echo "Alternatively, use dhcp, service, switch, node, xio, vplex  or avamar for settings specific to"
  echo "DHCP, CX/VNX Service Lan, Centera switch or node, XIO, Vplex or Avamar connections."
  exit 1
elif [ $# -gt "$MAXOPT" ]
then
  echo "Please enter IP and CIDR formatted subnet mask (20 through 30), gateway is optional."
  echo "Alternatively, use dhcp, service, switch, node, xio, vplex or avamar for settings specific to"
  echo "DHCP, CX/VNX Service Lan, Centera switch or node, XIO, Vplex or Avamar connections."
  exit 1
fi


# Common subnet masks
M30=255.255.255.252
M29=255.255.255.248
M28=255.255.255.240
M27=255.255.255.224
M26=255.255.255.192
M25=255.255.255.128
M24=255.255.255.0
M23=255.255.254.0
M22=255.255.252.0
M20=255.255.240.0

if [ "$2" = 30 ]
then
  MASK=${M30}
elif [ "$2" = 29 ]
then
  MASK=${M29}
elif [ "$2" = 28 ]
then
  MASK=${M28}
elif [ "$2" = 27 ]
then
  MASK=${M27}
elif [ "$2" = 26 ]
then
  MASK=${M26}
elif [ "$2" = 25 ]
then
  MASK=${M25}
elif [ "$2" = 24 ]
then
  MASK=${M24}
elif [ "$2" = 23 ]
then
  MASK=${M23}
elif [ "$2" = 22 ]
then
  MASK=${M22}
elif [ "$2" = 20 ]
then
MASK=${M20}
else
  MASK="$2"
fi

IP="$1"

if [ $# = 3 ]
then
  GATE=$3
  echo "Setting ip to "$IP", mask to "$MASK" and gateway to "$GATE"..."
  netsh interface ipv4 set address name="$LAN" source=static addr=$IP mask=$MASK gateway=$GATE
  exit 0
elif [ $# = 2 ]
then
  echo "Setting ip to "$IP" and netmask to "$MASK"..."
  netsh interface ipv4 set address name="$LAN" source=static addr=$IP mask=$MASK
  exit 0
fi
