#!/usr/bin/env bash
# Purpose: Test menu logic
# Date: 20190530
# Kevin Burg - kevin.burg@state.co.us

# Misc variable definitions {{{
# set -x # Enable debug

# }}}

# Function definitions {{{
header(){ # {{{ Header
echo -e "The favorites selector!\n"
} # }}} End header

fav_color(){ # {{{ First fcn
read -rep "What is your favorite color: " user_color
} # }}} End fav_color

fav_season(){ # {{{ Second fcn
read -rep "What is your favorite season: " user_season
} # }}} End fav_season

fav_food(){ # {{{ Third fcn
read -rep "What is your favorite food: " user_food
} # }}} End fav_food

fav_music(){ # {{{ Fourth fcn
read -rep "What is your favorite music: " user_music
} # }}} End fav_music

show_favorites() { # {{{
echo -e "These were your choices:"
echo -e "Color: ${user_color}"
echo -e "Season: ${user_season}"
echo -e "Food: ${user_food}"
echo -e "Music: ${user_music}"
read -rep "Do you agree with your choices [y/n]?" user_agree
} # }}} End show_favorites

# }}}

# Begin main tasks {{{
header
fav_color
fav_season
fav_food
fav_music
show_favorites
if [[ "${user_agree}" == "y" ]]; then
  echo -e "You responded ${user_agree}, so we are done"
  exit 0
elif [[ "${user_agree}" == "n" ]]; then
  echo -e "Which favorite would you like to change?"
  echo -e "[1] Color"
  echo -e "[2] Season"
  echo -e "[3] Food"
  echo -e "[4] Music"
  read -rep "Enter selection: " user_change
  case "${user_change}" in
    1)
    fav_color
    show_favorites
    ;;
    2)
    fav_season
    show_favorites
    ;;
    3)
    fav_food
    show_favorites
    ;;
    4)
    fav_music
    show_favorites
    ;;
  esac
else
  echo -e "I don't recognize that choice"
  exit
fi
# }}}

exit 0
