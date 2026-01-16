#!/bin/bash

while : ; do

  echo '/Home/Sections'
  echo
  echo 'Select a project section:'

  section_count=1
  declare -A section_numbers

  # Display project sections
  for section in ./projects/*/; do
    folder="${section%/}"
    folder="${folder##*/}"
    echo "$section_count. '$folder'"
    section_numbers[$section_count]=$folder
    ((section_count++))
  done

  # Display the option to go back to the main menu
  echo "$section_count. Go back to the main menu."

  # Read user's selected option from the input
  echo
  read -p "Enter choise: " selected_option

  # Import functions for validation
  source './scripts/validation.sh'

  # Check if the input is a positive integer
  if ! is_positive_integer "$selected_option"; then
    clear
    echo 'Failure: Input is not a positive integer! Try again.'
    continue
  fi

  if ((
    selected_option >= 1 &&
    selected_option < section_count
  )); then
    clear
    ./scripts/menus/projects.sh "${section_numbers[$selected_option]}"
  elif (( selected_option == section_count )); then
    clear
    break
  else
    clear
    echo "Failure: Choise must be between 1 and ${section_count}. Try again."
  fi

done
