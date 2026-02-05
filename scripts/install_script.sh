#!/bin/bash

# --- Functions ---

usage() {
  echo "Usage: $0 <project_dir> [option]"
  echo "Options:"
  echo "  -l, --local    Install for current user only (Default: ~/.local/bin)"
  echo "  -g, --global   Install for all users (Requires sudo: /usr/local/bin)"
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

if [[
  ! -f "$1/run.sh" ||
  ! -f "$1/info.sh"
]]; then
  echo -e "\e[1;31mError: Mandatory files doesn't exist.\e[0m"
  exit 1
fi

project_dir="$1"
mode='local'

# Get the mandatory variables
source "$project_dir"/info.sh

# Check all the mandatory variables
if [[ -z installed_script_name ]]; then
  usage
fi

# Check if second argument matches global flag
if [[ "$2" == "-g" || "$2" == "--global" ]]; then
    mode='global'
elif [[ -n "$2" && "$2" != "-l" && "$2" != "--local" ]]; then
    echo -e "\e[1;31mError: Unknown option '$2'\e[0m"
    usage
fi

readonly global_install_dir='/usr/local/bin'
readonly local_install_dir="$HOME/.local/bin"

# Check if the script is already installed globally or locally and reinstall if needed
if [[ -f "$global_install_dir/$installed_script_name" ]]; then
  echo -e "\e[1;31mError: This project is already installed for all users ($global_install_dir).\e[0m"
  if [[ "$mode" == 'local' ]]; then
    read -p 'Would you like to reinstall it for current user? ' agree_to_reinstall
    if [[ "${agree_to_reinstall,,}" == 'y' ]]; then
      echo 'Uninstalling the package...'
      sudo rm -i "$global_install_dir/$installed_script_name"
      if [[ -f "$global_install_dir/$installed_script_name" ]]; then
        echo -e "\e[1;31mReinstallation has been canceled.\e[0m"
        exit 1
      else
        echo 'Removed global installation. Package is reinstalling for current user...'
      fi
    else
      echo -e "\e[1;31mReinstallation has been canceled.\e[0m"
      exit 1
    fi
  else
    exit 1
  fi
elif [[ -f "$local_install_dir/$installed_script_name" ]]; then
  echo -e "\e[1;31mError: This project is already installed for current user ($local_install_dir).\e[0m"
  if [[ "$mode" == 'global' ]]; then
    read -p 'Would you like to reinstall it for all users? ' agree_to_reinstall
    if [[ "${agree_to_reinstall,,}" == 'y' ]]; then
      echo 'Uninstalling the package...'
      rm -i "$local_install_dir/$installed_script_name"
      if [[ -f "$local_install_dir/$installed_script_name" ]]; then
        echo -e "\e[1;31mReinstallation has been canceled.\e[0m"
        exit 1
      else
        echo 'Removed local installation. Package is reinstalling for all users...'
      fi
    else
      echo -e "\e[1;31mReinstallation has been canceled.\e[0m"
      exit 1
    fi
  else
    exit 1
  fi
fi

if [[ "$mode" == 'global' ]]; then
  install_dir="$global_install_dir"
  if [[ $EUID -ne 0 ]]; then
    sudo_cmd='sudo'
  else
    sudo_cmd=''
  fi
else
  install_dir="$local_install_dir"
  sudo_cmd=''
fi

final_install_path="$install_dir/$installed_script_name"

# Create the install directory if it doesn't exist
$sudo_cmd mkdir -p "$install_dir"

# Copy the script
$sudo_cmd cp "${project_dir}/run.sh" "$final_install_path"

# Make the script executable
$sudo_cmd chmod +x "$final_install_path"

# Verify installation
if [[ -x "$final_install_path" ]]; then
  echo -e "\e[1;32mSuccess: Script has been installed as '$installed_script_name'\e[0m"
else
  echo -e "\e[1;31mError: Installation failed\e[0m"
  exit 1
fi

# Check if the install directory is actually in the user's current PATH
if [[ ":$PATH:" != *":$install_dir:"* ]]; then
    echo "Warning: $install_dir is not in your \$PATH."
    echo "To run this script, you must add it to your path or run:"
    echo "  export PATH=\"\$PATH:$install_dir\""
else
    echo "You can now run the script by typing:"
    echo -e "  \e[1;32m$installed_script_name\e[0m"
fi
