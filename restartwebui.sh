#!/usr/bin/env zsh
# Purpose: Wrap up Dell/EMC restart web ui instructions in a script
#          Runs from the Isilon web interface
# Date: 20181023
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
f_green="\e[38;2;0;255;0m"
f_red="\e[38;2;255;0;0m"
reset="\e[0m"
# }}}

# Begin main tasks {{{
if (( $EUID != 0 )); then
  echo -e "${f_red}Must be root user! Exiting...${reset}"
  exit 1
else
  # Step 1
  echo -e "${f_green}Disabling the webui service${reset}"
  isi services -a isi_webui disable
  echo -e "${f_green}Waiting 10 seconds...${reset}"
  sleep 10

  # Step 2
  echo -e "${f_green}Killing the isi_webui_d process clusterwide${reset}"
  isi_for_array -s killall -9 isi_webui_d
  echo -e "${f_green}Waiting 10 seconds...${reset}"
  sleep 10

  # Step 3
  echo -e "${f_green}Enabling the webui service${reset}"
  isi services -a isi_webui enable

  # Step 4
  echo -e "${f_green}Remove old httpd PID files from the cluster${reset}"
  isi_for_array -s "rm -f /var/apache2/run/webui_httpd.pid"

  # Step 5
  echo -e "${f_green}Start up httpd process on the cluster${reset}"
  isi_for_array -s /usr/local/sbin/webui_httpd_ctl start
fi # }}}

exit 0
