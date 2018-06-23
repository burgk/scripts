#!/usr/bin/env bash
# Kevin Burg - burg.kevin@gmail.com
# Wrapper for ffmpeg to convert .ogg files to .mp3 files

# libmp3lame quality settings:
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

# FF=/usr/bin/ffmpeg
FF=$(which ffmpeg)
IFS='\'
INPUT=$1
# IFILEBASE=${1%%opus}
INFILEBASE=${1%.*}
INFILEEXT=${1##*.}
OUTPUT=${INFILEBASE}.mp3
# BITRATE=$(mediainfo ${INPUT} | grep "Overall bit rate" | cut -d: -f2 | cut -d' ' -f2)
# BITRATE=$(mediainfo ${INPUT} | grep -E 'Overall.*kb/s' | sed 's/[^0-9]//g')
let "BITRATE = $(mediainfo --Inform="General;%OverallBitRate%" ${INPUT}) / 1000"
F_RED="\e[38;2;255;0;0m"
F_GREEN="\e[38;2;0;255;0m"
RESET="\e[0m"

setcodescale()
{
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
}

encodefile()
{
$FF -hide_banner -loglevel panic -i ${INPUT} -acodec libmp3lame -qscale:a ${CODECSCALE}  -map_metadata 0:s:0 ${OUTPUT}
}

errormsg()
{
echo -e "${F_RED}Usage: $(basename $0) <inputfile>"
echo -e "Currently ogg and opus files are suported${RESET}"
}

if [ $# -eq 1 ]
 then
  if [ ${INFILEEXT} = ogg ] || [ ${INFILEEXT} = opus ]
   then
    setcodescale
    echo -e "${F_GREEN}Encoding ${INPUT} to ${OUTPUT} at ${CODECSCALE}${RESET}"
    encodefile
    exit 0
  else
   echo -e "Only ogg or opus files currently supported. Exiting."
   exit 1
  fi
 else
  errormsg
  exit 1
fi
