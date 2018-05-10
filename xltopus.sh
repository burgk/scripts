#!/usr/bin/env bash

# Wrapper for ffmpeg to convert .ogg files to .mp3 files
# At quality setting of 3 (~160k).

FF="/home/burgk/scripts/ffmpeg.exe"
# echo "Codec used: ${FF}"

IFS='\'

INPUT=$1
# EXTEN=$2
# echo "Input file: ${INPUT}"
# IFILEBASE=${1%%ogg}
IFILEBASE=${1%%opus}
# IFILEBASE=${1}%%${2}
# echo "Input base ${IFILEBASE}"

# INSIZE=${#INPUT}
# echo "Length of input: ${INSIZE}"
# CROPSIZE=${INSIZE}-3
# echo "Crop size = ${CROPSIZE}"

# OUTPUT=`rename .ogg .mp3 ${INPUT}`
# OUTPUT[$INSIZE]=( $INPUT )

# OUTPUT=`cut -b  --field=1`
# OUTPUT=${INPUT: (-3)}
OUTPUT=${IFILEBASE}mp3
# echo "Output file: ${OUTPUT}"


# echo "Codec used: ${FF}"
# echo "Input file: ${INPUT}"
# echo "Output file: ${OUTPUT[0]}"
# echo "Output file: ${OUTPUT}"

# exit 0

if [ $# -eq 1 ]
then
# IFS='\'
$FF -i $INPUT -acodec libmp3lame -qscale:a 3 -map_metadata 0:s:0 $OUTPUT
exit 0

else
# echo "Usage: xlt.sh <input.ogg> <output.mp3>"
echo "Usage: `basename $0` <input.file>"
exit 1
fi
