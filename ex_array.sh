#!/usr/bin/env bash
# Purpose: Demonstrate bash array usage
# Date: 20181024
# Kevin Burg - burg.kevin@gmail.com

# filecontent=( $(cat array-in.txt) )

# for t in "${filecontent[@]}"
# do
# 	echo $t
# done
# echo "Array has been read, it was ${#filecontent[@]} elements long."
# exit 0

# dirlist=( "$(find . -maxdepth 1 -type d | sort -n | cut -b 3-)" )
tmpfile="/tmp/largedir-tmp"
outfile="/tmp/largedir-out"
declare -a dirlist=()
while IFS= read -r -d $'\0'; do
  array+=("$REPLY")
done < <(find . -maxdepth 1 -type d -print0)

echo "dirlist array size is: ${#dirlist[@]}"
echo "element 0: ${dirlist[0]}"
echo "element 1: ${dirlist[1]}"
echo "entire array: "  "${dirlist[@]}"

for dir in "${dirlist[@]}"; do
  cd "${dir}" || exit
  size=$("du" -s | cut -f1) >/dev/null 2>&1
  echo -e "${size};${dir}" >> "${tmpfile}"
  cd .. || exit
done

echo -e "Size  in  KB;Directory" > "${outfile}"
echo -e "---m--g--t--;---------" >> "${outfile}"
sort -rn "${tmpfile}" >> "${outfile}"
