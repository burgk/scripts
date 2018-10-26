#!/bin/bash
UPSINCE=$(net statistics workstation | grep "Statistics since" | awk '{print $3, $4, $5;}')
echo -e "System last booted: ${UPSINCE}"
