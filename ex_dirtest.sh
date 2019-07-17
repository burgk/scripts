#!/usr/bin/bash

mypath=$(dirname "$0")
echo "$mypath"
echo "$PWD"
verify_path(){
patherr(){
echo "Sorry, path does not match"
}
if [[ "$mypath" == "$PWD" ]]; then
  echo "Path matches"
else
  patherr
#  echo "Nope"
fi
}
verify_path
exit 0
