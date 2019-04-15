#!/bin/bash
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

