#!/usr/bin/env bash
# Kevin Burg - burg.kevin@gmail.com
# Set foreground and background color constants
# For reference in other scripts

# Set foreground colors
F_RED="\033[1;31m"
F_GREEN="\033[1;32m"
F_YELLOW="\033[1;33m"
F_BLUE="\033[1;34m"
F_MAGENTA="\033[1;35m"
F_CYAN="\033[1;36m"
F_WHITE="\033[1;37m"
# Set background colors
B_RED="\033[1;41m"
B_GREEN="\033[1;42m"
B_YELLOW="\033[1;43m"
B_BLUE="\033[1;44m"
B_MAGENTA="\033[1;45m"
B_CYAN="\033[1;46m"
B_WHITE="\033[1;47m"
# Non color settings
BOLD="\033[1m"
RESET="\033[0m"

echo -e "${F_RED} Hello${RESET} ${B_RED}World${RESET}"
echo -e "${F_YELLOW}${B_GREEN}TESTING!${RESET}"
echo -e "Back to plain :-("
echo -e "${F_MAGENTA}Yep, it stays this way until"
echo -e "You put in the reset"
echo -e "${RESET}See.."
