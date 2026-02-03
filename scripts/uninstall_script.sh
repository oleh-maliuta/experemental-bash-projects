#!/bin/bash

# --- Functions ---

usage() {
  echo "Usage: $0 <project_dir> [option]"
  exit 1
}

# --- Main Logic ---

# Validate input
if [[ -z "$1" ]]; then
  usage
fi

# Check if the directory and the mandatory files exists
if [[ ! -d "$1" ]]; then
  echo -e "\e[1;31mError: Directory doesn't exist.\e[0m"
  exit 1
fi

if [[ ! -f "$1/info.sh" ]]; then
  echo -e "\e[1;31mError: info.sh file doesn't exist.\e[0m"
  exit 1
fi

# Get the mandatory variables
source "$1"/info.sh

# Check all the mandatory variables
if [[ -z installed_script_name ]]; then
  usage
fi

# Check Global
if [[ -f "/usr/local/bin/$installed_script_name" ]]; then
  echo "Found '$installed_script_name' in /usr/local/bin"
  sudo rm -i "/usr/local/bin/$installed_script_name"
  echo -e "\e[1;32mRemoved global installation.\e[0m"
  exit 0
fi

# Check Local
if [[ -f "$HOME/.local/bin/$installed_script_name" ]]; then
  echo "Found '$installed_script_name' in $HOME/.local/bin"
  rm -i "$HOME/.local/bin/$installed_script_name"
  echo -e "\e[1;32mRemoved local installation.\e[0m"
  exit 0
fi

echo -e "\e[1;31mError: script '$installed_script_name' not found in local or global bins.\e[0m"
exit 1
