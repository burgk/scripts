#!/usr/bin/bash

# echo -e "Loading AD provider list..."
# declare -a adslist=( $(isi auth ads list --no-header --no-footer | grep online | cut -d" " -f1) )
# echo -e "Done, continuing\n"

prompt_sloc () {
echo -e "Loading AD provider list..."
declare -a adslist=( $(isi auth ads list --no-header --no-footer | grep online | cut -d" " -f1) )
echo -e "Done, continuing\n"

# echo "Size of array: $#"
# echo "$@"

PS3="Enter Selection: "
select user_sloc in "${adslist[@]}"; do # in "$@" is the default
#  if [[ "${REPLY}" -lt "1" ]] || [[ "${REPLY}" -gt "$#" ]]; then
#    echo -e "Out of range, exiting"
#  else
#    echo "You selected $option which is option $REPLY"
#    valid_opt="true"
#    break;
#  fi
  valid_opt="true"
  break;
#  user_sloc="${option}"
done
}

valid_opt="false"
while [[ "${valid_opt}" = "false" ]]; do
prompt_sloc # "${adslist[@]}"
done
echo "${user_sloc}"

# sed -e 's/,"/\>/g' testlog.txt  | tr -d "\"" | tr -d "{}" > filterlog.txt
