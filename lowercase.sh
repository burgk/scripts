#!/bin/bash
# change all filenames in directory to lowercase
 
IFS=\

for FILE in *
  do
    mv $FILE `echo $FILE | tr '[A-Z]' '[a-z]'`
  done
