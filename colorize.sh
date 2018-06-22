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
F_BLACK="\e[1;30m"
F_RED="\e[1;31m"
F_GREEN="\e[1;32m"
F_YELLOW="\e[1;33m"
F_BLUE="\e[1;34m"
F_MAGENTA="\e[1;35m"
F_CYAN="\e[1;36m"
F_WHITE="\e[1;37m"

# Set 8 bit background colors
B_BLACK="\e[1;40m"
B_RED="\e[1;41m"
B_GREEN="\e[1;42m"
B_YELLOW="\e[1;43m"
B_BLUE="\e[1;44m"
B_MAGENTA="\e[1;45m"
B_CYAN="\e[1;46m"
B_WHITE="\e[1;47m"

# Non color settings
BOLD="\e[1m"
RESET="\e[0m"

# Demonstrate:
echo -e "${F_RED} Hello${RESET} ${B_RED}World${RESET}"
echo -e "${F_YELLOW}${B_GREEN}TESTING!${RESET}"
echo -e "Back to plain :-("
echo -e "${F_MAGENTA}Yep, it stays this way until"
echo -e "You put in the reset"
echo -e "${RESET}See.."
echo -e "\e[38;2;255;82;197;48;2;155;106;0mFancy${RESET} stuff"
