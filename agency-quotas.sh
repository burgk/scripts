#!/bin/bash
# Get my agency Isilon capacity usage
# Kevin Burg - kevin.burg@state.co.us

isi quota list \
| awk '{ if ( $3 == "/ifs/CDOT" \
|| $3 == "/ifs/CDOTDMZ" \
|| $3 == "/ifs/CDA" \
|| $3 == "/ifs/CDHS" \
|| $3 == "/ifs/CDHSHIPAA" ) print $3,$8 }' \
| sort
