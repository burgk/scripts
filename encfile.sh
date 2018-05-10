#!/usr/bin/bash
 
# Make sure we get a file name
if [ $# -lt 1 ]
then
echo "Usage: $0 file-to-encrypt"
exit 1
fi
openssl enc -e -aes256 -in "$1" -out "$1".enc 
