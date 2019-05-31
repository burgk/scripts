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

fav_food(){ # {{{ Third fcn
read -rep "What is your favorite food: " user_food
} # }}} End fav_food

fav_music(){ # {{{ Fourth fcn
read -rep "What is your favorite music: " user_music
} # }}} End fav_music

fav_season(){ # {{{ Second fcn
read -rep "What is your favorite season: " user_season
} # }}} End fav_season

show_favorites() { # {{{ Prompt for confirmation - vars: user_agree
user_agree="n"
echo -e "These were your choices:"
echo -e "Color: ${user_color}"
echo -e "Food: ${user_food}"
echo -e "Music: ${user_music}"
echo -e "Season: ${user_season}"
read -rep "Do you agree with your choices [y/n]?" user_agree
} # }}} End show_favorites

# }}}

# Begin main tasks {{{
header
fav_color
fav_food
fav_music
fav_season
show_favorites
while [ "${user_agree}" == "n" ]; do
  echo -e "Which favorite would you like to change?"
  echo -e "[1] Color"
  echo -e "[2] Food"
  echo -e "[3] Music"
  echo -e "[4] Season"
  read -rep "Enter selection: " user_change
  case "${user_change}" in
    1)
    fav_color
    show_favorites
    ;;
    2)
    fav_food
    show_favorites
    ;;
    3)
    fav_music
    show_favorites
    ;;
    4)
    fav_season
    show_favorites
    ;;
  esac
done
echo -e "Since you like these favorites, here they are:"
echo -e "Color: ${user_color}"
echo -e "Food: ${user_food}"
echo -e "Music: ${user_music}"
echo -e "Season: ${user_season}"
echo -e "We're done now, so goodbye!"
# }}}

exit 0
