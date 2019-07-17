#!/bin/bash
spinner_1(){
while true
do
  printf "."
  printf -- "-%.0s"
  sleep 0.10

  printf -- "\b \b\b%.0b"
  printf -- "\\%.0s"
  sleep 0.10

  printf -- "\b%.0s"
  printf -- "|%.0s"
  sleep 0.10

  printf -- "\b%.0s"
  printf -- "/%.0s"
  sleep 0.10

  printf -- "\b%.0s"
  printf -- "."
done
}

spinner_2(){
while true; do for X in '-' '/' '|' '\'; do echo -en "\b$X"; sleep 0.1; done; done
}

read -rp "Which spinner, 1 or 2: " user_ans
case "${user_ans}" in
  1)
    spinner_1
  ;;
  2)
    spinner_2
  ;;
  *)
    echo -e "Invalid choice, exiting!"
    exit 1
  ;;
esac
