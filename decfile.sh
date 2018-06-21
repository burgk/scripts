#!/usr/bin/bash
# Kevin Burg - burg.kevin@gmail.com
# Openssl based file decryption
if [ $# -lt 2 ]
then
echo "Usage: $0 file-to-decrypt new-file-name"
exit 1
fi
openssl enc -d -aes256 -in "$1" -out "$2"
