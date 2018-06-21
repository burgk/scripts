#!/usr/bin/env bash
# Kevin Burg - burg.kevin@gmail.com
# Wrapper for mpv
if [ $# -eq 1 ]
then
   
  # Added this line below to handle any spaces in the input filename
  # Found on page 42 of the Advanced Bash Scripting Guide
   
  IFS='\'
   
   mpv --speed 1.5 ${1}
  exit 0
 
else
  echo "Usage: vplay.sh filename"
  exit 1
fi
