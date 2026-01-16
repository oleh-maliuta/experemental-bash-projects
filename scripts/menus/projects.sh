#!/bin/bash

while : ; do

  echo "/Home/Sections/$1"
  echo
  echo 'Select a project:'

  project_count=1
  declare -A  project_numbers

  # Display projects
  for project in ./projects/"$1"/*/; do
    folder="${project%/}"
    folder="${folder##*/}"
    echo "$project_count. '$folder'"
    project_numbers[$project_count]=$folder
    ((project_count++))
  done

  # Display the option to go back to the sections list menu
  echo "$project_count. Go back to the sections list menu."

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
    selected_option < project_count
  )); then
    clear
    echo "Selected '${project_numbers[$selected_option]}'"
  elif (( selected_option == project_count )); then
    clear
    break
  else
    clear
    echo "Failure: Choise must be between 1 and ${project_count}. Try again."
  fi

done
