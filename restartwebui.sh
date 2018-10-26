#!/usr/bin/env zsh
# Wrap up Dell/EMC restart web ui instructions in a script
# Kevin Burg - kevin.burg@state.co.us 20181023

F_GREEN="\e[38;2;0;255;0m"
F_RED="\e[38;2;255;0;0m"
RESET="\e[0m"

if (( $EUID != 0 )); then
  echo -e "${F_RED}Must be root user! Exiting...${RESET}"
  exit 1
else
  # Step 1
  echo -e "${F_GREEN}Disabling the webui service${RESET}"
  isi services -a isi_webui disable
  echo -e "${F_GREEN}Waiting 10 seconds...${RESET}"
  sleep 10

  # Step 2
  echo -e "${F_GREEN}Killing the isi_webui_d process clusterwide${RESET}"
  isi_for_array -s killall -9 isi_webui_d
  echo -e "${F_GREEN}Waiting 10 seconds...${RESET}"
  sleep 10

  # Step 3
  echo -e "${F_GREEN}Enabling the webui service${RESET}"
  isi services -a isi_webui enable

  # Step 4
  echo -e "${F_GREEN}Remove old httpd PID files from the cluster${RESET}"
  isi_for_array -s "rm -f /var/apache2/run/webui_httpd.pid"

  # Step 5
  echo -e "${F_GREEN}Start up httpd process on the cluster${RESET}"
  isi_for_array -s /usr/local/sbin/webui_httpd_ctl start
fi
exit 0
