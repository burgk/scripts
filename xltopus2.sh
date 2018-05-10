#!/usr/bin/env bash

# Wrapper for ffmpeg to convert .ogg files to .mp3 files
# lame quality settings:
# 0 = ~245 - range: 220-260
# 1 = ~225 - range: 190-250
# 2 = ~190 - range: 170-210
# 3 = ~175 - range: 150-195
# 4 = ~165 - range: 140-185
# 5 = ~130 - range: 120-150
# 6 = ~115 - range: 100-130
# 7 = ~100 - range: 80-120
# 8 = ~85 - range: 70-105
# 9 = ~65 - range: 45-85

FF=/usr/bin/ffmpeg
IFS='\'
INPUT=$1
IFILEBASE=${1%%opus}
OUTPUT=${IFILEBASE}mp3
BITRATE=$(mediainfo ${INPUT} | grep "Overall bit rate" | cut -d: -f2 | cut -d' ' -f2)

if [ ${BITRATE} -lt "65" ]
then CODECSCALE=9
elif [ ${BITRATE} -lt "85" ]
then CODECSCALE=8
elif [ ${BITRATE} -lt "100" ]
then CODECSCALE=7
elif [ ${BITRATE} -lt "115" ]
then CODECSCALE=6
elif [ ${BITRATE} -lt "130" ]
then CODECSCALE=5
elif [ ${BITRATE} -lt "165" ]
then CODECSCALE=4
elif [ ${BITRATE} -lt "175" ]
then CODECSCALE=3
elif [ ${BITRATE} -lt "190" ]
then CODECSCALE=2
elif [ ${BITRATE} -lt "225" ]
then CODECSCALE=1
elif [ ${BITRATE} -lt "245" ]
then CODECSCALE=0
fi

if [ $# -eq 1 ]
then
	echo -e "Encoding ${INPUT} to ${OUTPUT} at ${CODECSCALE}"
$FF -i ${INPUT} -acodec libmp3lame -qscale:a ${CODECSCALE}  -map_metadata 0:s:0 ${OUTPUT}
exit 0

else
echo "Usage: $(basename $0) <input.file>" 
exit 1
fi
