#!/usr/bin/env bash
# Purpose: Wrapper for ffmpeg to convert ogg and opus files to .mp3 files
# Date: 20180321
# Kevin Burg - burg.kevin@gmail.com

# Comments {{{
# To match both *.opus and *.ogg files, try this in your for loop:
# ls @(*.ogg|*.opus)
# Requires extglob to be set in the shell
# Set with shopt +s extglob

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
# }}}

# Various definitions {{{
# set -x # enable debug mode
IFS='\'
input=${1}
infilebase=${1%.*}
infileext=${1##*.}
output=${infilebase}.mp3
f_red="\e[38;2;255;0;0m"
f_green="\e[38;2;0;255;0m"
reset="\e[0m"
# }}}

# Validate necessary commands {{{
if command -v ffmpeg > /dev/null 2>&1
 then
  ff=$(command -v ffmpeg)
 else
  echo -e "${f_red}ffmpeg not found, exiting${reset}"
  exit 1
fi

if command -v mediainfo > /dev/null 2>&1
 then
  mi=$(command -v mediainfo)
 else
  echo -e "${f_red}mediainfo not found, exiting${reset}"
  exit 1
fi
# }}}

setcodescale() # {{{
{
# let "bitrate = $(${mi} --Inform="General;%OverallBitRate%" ${input}) / 1000"
(( bitrate = $(${mi} --Inform="General;%OverallBitRate%" "${input}") / 1000 ))
if [ ${bitrate} -lt "65" ]
 then codescale=9
elif [ ${bitrate} -lt "85" ]
 then codescale=8
elif [ ${bitrate} -lt "100" ]
 then codescale=7
elif [ ${bitrate} -lt "115" ]
 then codescale=6
elif [ ${bitrate} -lt "130" ]
 then codescale=5
elif [ ${bitrate} -lt "165" ]
 then codescale=4
elif [ ${bitrate} -lt "175" ]
 then codescale=3
elif [ ${bitrate} -lt "190" ]
 then codescale=2
elif [ ${bitrate} -lt "225" ]
 then codescale=1
elif [ ${bitrate} -lt "245" ]
 then codescale=0
fi
} # }}}

encodefile() # {{{
{
${ff} -hide_banner -loglevel info -i "${input}" -acodec libmp3lame -qscale:a ${codescale}  -map_metadata 0:s:0 "${output}"
} # }}}

errormsg() # {{{
{
echo -e "${f_red}Usage: $(basename "$0") <inputfile>"
echo -e "Currently ogg and opus files are suported"
echo -e "Requires ffmpeg and mediainfo to be installed${reset}"
} # }}}

# Begin main tasks {{{
if [ $# -eq 1 ]
 then
  if [ "${infileext}" = ogg ] || [ "${infileext}" = opus ]
   then
    setcodescale
    echo -e "${f_green}Encoding ${input} to ${output} at ${codescale}${reset}"
    encodefile
    exit 0
  else
   echo -e "${f_red}Only ogg and opus files currently supported. Exiting.${reset}"
   exit 1
  fi
 else
  errormsg
  exit 1
fi # }}}

exit 0
