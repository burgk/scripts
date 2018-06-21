#!/usr/bin/bash
# Kevin Burg - burg.kevin@gmail.com 
# Openssl based file encryption
if [ $# -lt 1 ]
then
echo "Usage: $0 file-to-encrypt"
exit 1
fi
openssl enc -e -aes256 -in "$1" -out "$1".enc 
