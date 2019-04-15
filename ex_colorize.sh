#!/usr/bin/env bash
# Kevin Burg - burg.kevin@gmail.com
# Set foreground and background color constants
# For reference in other scripts
# \e \033 \x1b are all equivalent, \e is shorter

# 256 color mode:
# foreground \e[38;5;#m
# background \e[48;5;#m
# 0-7 standard colors
# 8-15 high intensity colors
# 16-231 colors
# 232-255 gray scale dark->light

# True color mode:
# foreground \e[38;2;<r>;<g>;<b>m
# background \e[48;2;<r>;<g>;<b>m

# Set 8 bit foreground colors
f_black="\e[1;30m"
f_red="\e[1;31m"
f_green="\e[1;32m"
f_yellow="\e[1;33m"
f_blue="\e[1;34m"
f_magenta="\e[1;35m"
f_cyan="\e[1;36m"
f_white="\e[1;37m"

# Set 8 bit background colors
b_black="\e[1;40m"
b_red="\e[1;41m"
b_green="\e[1;42m"
b_yellow="\e[1;43m"
b_blue="\e[1;44m"
b_magenta="\e[1;45m"
b_cyan="\e[1;46m"
b_white="\e[1;47m"

# Non color settings
bold="\e[1m"
reset="\e[0m"

# Demonstrate:
echo -e "${f_red}Hello${reset} ${b_red}World${reset}"
echo -e "${f_yellow}${b_green}TESTING!${reset}"
echo -e "Back to plain :-("
echo -e "${f_magenta}Yep, it stays this way until"
echo -e "You put in the reset"
echo -e "${reset}See.."
echo -e "\e[38;2;255;82;197;48;2;155;106;0mFancy${reset} stuff"
exit 0
