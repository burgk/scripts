#!/usr/bin/env bash
# Kevin Burg - burg.kevin@gmail.com
# Wrapper for ffmpeg to convert .ogg files to .mp3 files
# At quality setting of 3 (~160k).

FF=/cygdrive/f/cygwin64/home/burgk/scripts/ffmpeg.exe

if [ $# -eq 2 ]
then
IFS='\'
$FF -i $1 -acodec libmp3lame -qscale:a 3 $2
exit 0

else
echo "Usage: xlt.sh <input.ogg> <output.mp3>"
exit 1
fi
