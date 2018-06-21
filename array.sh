#!/usr/bin/env bash
# Kevin Burg - burg.kevin@gmail.com
# Basic bash array example
filecontent=( $(cat array-in.txt) )

for t in "${filecontent[@]}"
do
	echo $t
done
echo "Array has been read, it was ${#filecontent[@]} elements long."
exit 0
