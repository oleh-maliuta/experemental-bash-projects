#!/bin/bash

echo 'Welcome to the list of my projects for Bash learning!'
echo
echo 'Select an action:'

main_option_headers=(
'Open the projects list.'
'Quit.'
)
main_option_scripts=(
'./scripts/project_handler.sh'
'echo Exited the script!'
)

# Display options
for option_idx in "${!main_option_headers[@]}"
do
echo "$((option_idx + 1)). ${main_option_headers[$option_idx]}"
done

# Read user's selected option from the input
read -p "Enter choise: " selected_option

# Check if the input is a positive integer
if [[ ! "$selected_option" =~ ^[0-9]+$ ]]
then
echo 'Error: Input is not a valid integer!'
exit 1
fi

# Check if the integer input is within the valid range
if [[
! "$selected_option" -ge 1 ||
! "$selected_option" -le "${#main_option_headers[@]}"
]]; then
echo "Error: Choise must be between 1 and ${#main_option_headers[@]}"
exit 1
fi

# Execute the selected action
echo
eval "${main_option_scripts[$((selected_option - 1))]}"
