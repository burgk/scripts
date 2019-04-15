#!/usr/bin/env bash
# Purpose: Demonstrate bash array usage
# Date: 20181024
# Kevin Burg - burg.kevin@gmail.com

filecontent=( $(cat array-in.txt) )

for t in "${filecontent[@]}"
do
	echo $t
done
echo "Array has been read, it was ${#filecontent[@]} elements long."
exit 0
