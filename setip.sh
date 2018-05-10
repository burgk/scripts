#!/usr/bin/env bash
# Script to set ip address vi cli
# Can set ip + subnet or ip + subnet + gateway
# 4 options allow for dhcp, service lan and Centera node / switch configs

MINOPT=2
MAXOPT=3
LAN="Local Area Connection"

if [ "$1" = "dhcp" ]
then
	echo "Setting IP via DHCP"
	netsh interface ipv4 set address name="$LAN" source=dhcp
	netsh interface ipv4 set dnsservers name="LAN" source=dhcp
elif [ "$1" = "service" ]
then
	echo "Setting IP for CX/VNX Service LAN connection"
	netsh interface ipv4 set address name="$LAN" source=static addr=128.221.1.249 mask=255.255.255.248
elif [ "$1" = "switch" ]
then
	echo "Setting IP for Centera Cube Switch connection"
	netsh interface ipv4 set address name="LAN" source=static addr=10.255.1.37 mask=255.255.255.192
elif [ "$1" = "node" ]
then
	echo "Setting IP for Centera Node connection"
	netsh interface ipv4 set address name="LAN" source=static addr=10.255.0.2 mask=255.255.255.252
exit 0
elif [ $# -lt "$MINOPT" ]
then
echo "Must enter IP and subnet mask, gateway is optional.  Mask is one of 22 through 30."
exit 1
elif [ $# -gt "$MAXOPT" ]
then
echo "Must enter IP and subnet mask, gateway is optional.  Mask is one of 22 through 30."
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

if [ $2 = 30 ]
then
MASK=${M30}
elif [ $2 = 29 ]
then
MASK=${M29}
elif [ $2 = 28 ]
then
MASK=${M28}
elif [ $2 = 27 ]
then
MASK=${M27}
elif [ $2 = 26 ]
then
MASK=${M26}
elif [ $2 = 25 ]
then
MASK=${M25}
elif [ $2 = 24 ]
then
MASK=${M24}
elif [ $2 = 23 ]
then
MASK=${M23}
elif [ $2 = 22 ]
then
MASK=${M22}
else
MASK=$2
fi

IP="$1"

if [ $# = 3 ]
then
	GATE=$3
	echo "Setting ip to "$IP", mask to "$MASK" and gateway to "$GATE"..."
	netsh interface ip set address name="$LAN" source=static addr=$IP mask=$MASK gateway=$GATE 
exit 0
elif [ $# = 2 ]
then
	echo "Setting ip to "$IP" and netmask to "$MASK"..."
	netsh interface ip set address name="$LAN" source=static addr=$IP mask=$MASK
exit 0
fi
