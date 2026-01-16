#!/bin/bash

clear
echo -e "\e[1;32mWelcome to the list of my projects for Bash learning!\e[0m"
echo

main_option_headers=(
'Open the projects list.'
'Quit.'
)

while : ; do

  echo -e '\e[1;34mLocation:\e[0m \e[1;32m\e[44m /Home \e[0m'
  echo
  echo 'Select an action:'

  # Display options
  for option_idx in "${!main_option_headers[@]}"; do
    echo "$((option_idx + 1)). ${main_option_headers[$option_idx]}"
  done

  # Read user's selected option from the input
  echo
  read -p "Enter choise: " selected_option

  # Import functions for validation
  source './scripts/validation.sh'

  # Check if the input is a positive integer
  if ! is_positive_integer "$selected_option"; then
    clear
    echo 'Failure: Input is not a positive integer! Try again.'
    echo
    continue
  fi

  # Execute the selected action
  clear
  case $selected_option in
    1)
      ./scripts/menus/sections.sh
    ;;
    2)
     break
    ;;
    *)
      echo "Failure: Choise must be between 1 and ${#main_option_headers[@]}. Try again."
      echo
  esac

done
