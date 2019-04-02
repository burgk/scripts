#!/usr/bin/env bash
# Purpose: Utility to start, stop or query the status of the Cisco services
#          It tries to be reasonably careful, but there are no guarantees :-)
# Date: 20181024
# Kevin Burg - burg.kevin@gmail.com

if [ $# -ne 1 ]
then
echo "Usage: cisco.sh start, status or stop."
exit 1
fi

NAMSTATE=`sc query nam | grep STATE | awk '{ print $4 }'`
NAMLMSTATE=`sc query namlm | grep STATE | awk '{ print $4 }'`
VPNAGENTSTATE=`sc query vpnagent | grep STATE | awk '{ print $4 }'`
CSAGENTSTATE=`sc query CSAgent | grep STATE | awk '{ print $4 }'`
CSAGENTMONSTATE=`sc query CSAgentMon | grep STATE | awk '{ print $4 }'`
CISCODSTATE=`sc query ciscod.exe | grep STATE | awk '{ print $4 }'`

if [ $1 = status ]
then
echo "Cisco AnyConnect Network Access Manager status: ${NAMSTATE}"
echo "Cisco AnyConnect Network Access Manager Logon Module status: ${NAMLMSTATE}"
echo "Cisco AnyConnect Secure Mobility Agent status: ${VPNAGENTSTATE}"
echo "Cisco Security Agent status: ${CSAGENTSTATE}"
echo "Cisco Security Agent Monitor status: ${CSAGENTMONSTATE}"
echo "Cisco Security Service status: ${CISCODSTATE}"
exit 0

elif [ $1 = start ]
then
	if [ "${NAMSTATE}" =  "RUNNING" ]
	then
	echo "Cisco AnyConnect Network Access Manager is already running..."
	else
	echo "Starting Cisco AnyConnect Network Access Manager..." 
	NAMTMP=`sc start nam | grep STATE | awk '{ print $4 }'`
	echo "Cisco AnyConnect Network Access Manager state: ${NAMTMP}"
	sleep 2
	NAMTMP=`sc query nam | grep STATE | awk '{ print $4 }'`
	echo "Cisco AnyConnect Network Access Manager state: ${NAMTMP}"
	fi

	if [ "${NAMLMSTATE}" = "RUNNING" ]
	then
	echo "Cisco Anyconnect Network Access Manager Logon Module is already running..."
	else
	echo "Starting Cisco AnyConnect Network Access Manager Logon Module..."
	NAMLMTMP=`sc start namlm | grep STATE | awk '{ print $4 }'`
	echo "Cisco AnyConnect Access Manager Logon Module status: ${NAMLMTMP}"
	sleep 2
	NAMLMTMP=`sc query namlm | grep STATE | awk '{ print $4 }'`
	echo "Cisco AnyConnect Access Manager Logon Module status: ${NAMLMTMP}"
	fi

	if [ "${VPNAGENTSTATE}" = "RUNNING" ]
	then
	echo "Cisco AnyConnect Secure Mobility Agent is already running..."
	else
	echo "Starting Cisco AnyConnect Secure Mobility Agent..."
	VPNAGENTTMP=`sc start vpnagent | grep STATE | awk '{ print $4 }'`
	echo "Cisco AnyConnect Secure Mobility Agent status: ${VPNAGENTTMP}"
	sleep 2
	VPNAGENTTMP=`sc query vpnagent | grep STATE | awk '{ print $4 }'`
	echo "Cisco AnyConnect Secure Mobility Agent status: ${VPNAGENTTMP}"
	fi

	if [ "${CSAGENTSTATE}" = "RUNNING" ]
	then
	echo "Cisco Security Agent is already running..."
	else
	echo "Starting Cisco Security Agent..."
	CSAGENTTMP=`sc start CSAgent | grep STATE | awk '{ print $4 }'`
	echo "Cisco Security Agent status: ${CSAGENTTMP}"
	sleep 2
	CSAGENTTMP=`sc query CSAgent | grep STATE | awk '{ print $4 }'`
	echo "Cisco Security Agent status: ${CSAGENTTMP}"
	fi

	if [ "${CSAGENTMONSTATE}" = "RUNNING" ]
	then
	echo "Cisco Security Agent Monitor is already running..."
	else
	echo "Starting Cisco Security Agent Monitor..."
	CSAGENTMONTMP=`sc start CSAgentMon | grep STATE | awk '{ print $4 }'`
	echo "Cisco Security Agent Monitor status: ${CSAGENTMONTMP}"
	sleep 2
	CSAGENTMONTMP=`sc query CSAgentMon | grep STATE | awk '{ print $4 }'`
	echo "Cisco Security Agent Monitor status: ${CSAGENTMONTMP}"
	fi

	if [ "${CISCODSTATE}" = "RUNNING" ]
	then
	echo "Cisco Security Service is already running..."
	else
	echo "Starting Cisco Security Service..."
	CISCODTMP=`sc start ciscod.exe | grep STATE | awk '{ print $4 }'`
	echo "Cisco Security Service status: ${CISCODTMP}"
	sleep 2
	CISCODTMP=`sc query ciscod.exe | grep STATE | awk '{ print $4 }'`
	echo "Cisco Security Service status: ${CISCODTMP}"
	fi

	exit 0

elif [ $1 = stop ]
then
	if [ "${NAMSTATE}" = "STOPPED" ]
	then
	echo "Cisco AnyConnect Network Access Manager is already stopped..."
	else
	echo "Stopping Cisco AnyConnect Network Access Manager..." 
	NAMTMP=`sc stop nam | grep STATE | awk '{ print $4 }'`
	echo "Cisco AnyConnect Network Access Manager state: ${NAMTMP}"
	sleep 2
	NAMTMP=`sc query nam | grep STATE | awk '{ print $4 }'`
	echo "Cisco AnyConnect Network Access Manager state: ${NAMTMP}"
	fi

	if [ "${NAMLMSTATE}" = "STOPPED" ]
	then
	echo "Cisco AnyConnect Network Access Manager Logon Module is already stopped..."
	else
	echo "Stopping Cisco AnyConnect Network Access Manager Logon Module..."
	NAMLMTMP=`sc stop namlm | grep STATE | awk '{ print $4 }'`
	echo "Cisco AnyConnect Access Manager Logon Module status: ${NAMLMTMP}"
	sleep 2
	NAMLMTMP=`sc query namlm | grep STATE | awk '{ print $4 }'`
	echo "Cisco AnyConnect Access Manager Logon Module status: ${NAMLMTMP}"
	fi

	if [ "${VPNAGENT}" = "STOPPED" ]
	then
	echo "Cisco AnyConnect Secure Mobility Agent is already stopped..."
	else
	echo "Stopping Cisco AnyConnect Secure Mobility Agent..."
	VPNAGENTTMP=`sc stop vpnagent | grep STATE | awk '{ print $4 }'`
	echo "Cisco AnyConnect Secure Mobility Agent status: ${VPNAGENTTMP}"
	sleep 2
	VPNAGENTTMP=`sc query vpnagent | grep STATE | awk '{ print $4 }'`
	echo "Cisco AnyConnect Secure Mobility Agent status: ${VPNAGENTTMP}"
	fi

	if [ "${CSAGENTSTATE}" = "STOPPED" ]
	then
	echo "Cisco Security Agent is already stopped..."
	else
	echo "Stopping Cisco Security Agent..."
	CSAGENTTMP=`sc stop CSAgent | grep STATE | awk '{ print $4 }'`
	echo "Cisco Security Agent status: ${CSAGENTTMP}"
	sleep 2
	CSAGENTTMP=`sc query CSAgent | grep STATE | awk '{ print $4 }'`
	echo "Cisco Security Agent status: ${CSAGENTTMP}"
	fi

	if [ "${CSAGENTMONSTATE}" = "STOPPED" ]
	then
	echo "Cisco Security Agent Monitor is already stopped..."
	else
	echo "Stopping Cisco Security Agent Monitor..."
	CSAGENTMONTMP=`sc stop CSAgentMon | grep STATE | awk '{ print $4 }'`
	echo "Cisco Security Agent Monitor status: ${CSAGENTMONTMP}"
	sleep 2
	CSAGENTMONTMP=`sc query CSAgentMon | grep STATE | awk '{ print $4 }'`
	echo "Cisco Security Agent Monitor status: ${CSAGENTMONTMP}"
	fi

	if [ "${CISCODSTATE}" = "STOPPED" ]
	then
	echo "Cisco Security Service is already stopped..."
	else
	echo "Stopping Cisco Security Service..."
	CISCODTMP=`sc stop ciscod.exe | grep STATE | awk '{ print $4 }'`
	echo "Cisco Security Service status: ${CISCODTMP}"
	sleep 2
	CISCODTMP=`sc query ciscod.exe | grep STATE | awk '{ print $4 }'`
	echo "Cisco Security Service status: ${CISCODTMP}"
	fi
	exit 0

else
echo "Usage: cisco.sh start, status or stop."
exit 1

fi
exit 0
