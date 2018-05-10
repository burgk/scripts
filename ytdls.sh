#!/usr/bin/env bash
# Use to download song playlists, can work for single songs
 
# if [ $# -eq 1 ]
# then
   
  # Added this line below to handle any spaces in the input filename
  # Found on page 42 of the Advanced Bash Scripting Guide
   
IFS='\'
   
youtube-dl -o "%(autonumber)s - %(title)s.%(ext)s" --autonumber-size 2 -x --prefer-ffmpeg --ffmpeg-location ~/scripts ${1}
exit 0
 
# else
# echo "Usage: ytdls.sh <playlist url> or <song url>"
# echo "Useful options: --playlist-start <#>, --playlist-end <#> or --playlist-items <#-#,#>"
# exit 1
# fi
