#!/usr/bin/env bash
# Kevin Burg - burg.kevin@gmail.com 
# Wrapper for youtube-dl
if [ $# -eq 1 ]
then
   
  # Added this line below to handle any spaces in the input filename
  # Found on page 42 of the Advanced Bash Scripting Guide
   
  IFS='\'
   
  youtube-dl -o "%(autonumber)s - %(title)s.%(ext)s" --autonumber-size 3 ${1}
  exit 0
 
else
  echo "Usage: ytdlp.sh filename"
  exit 1
fi
