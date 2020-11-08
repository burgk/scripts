#!/usr/bin/sh
# Kevin Burg - burg.kevin@gmail.com
# Don't remember where I found this...

shopt -s extglob

while read key; do
  case "$key" in
    *\ @(SHA256|MD5):[0-9a-zA-Z\+\/=]*)
    echo "$key" | cut -f2 -d' '
  ;;
  *)
    # Fall back to filename.  Note that commercial ssh is handled
    # explicitly in ssh_l and ssh_f, so hopefully this rule will
    # never fire.
    echo "Can\'t determine fingerprint from the following line, falling back to filename"
    echo "$key"
    basename "$key" | sed 's/[ (].*//'
  ;;

done | xargs
