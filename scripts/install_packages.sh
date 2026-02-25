#!/bin/bash

# Check if packages were provided as arguments
if [ $# -eq 0 ]; then
  echo -e "\033[1;31mError: No packages specified.\033[0m"
  echo "Usage: $0 <package1> <package2> ..."
  exit 1
fi

packages="$@"

# Run commands with sudo if not root
run_priv() {
  if [ "$EUID" -ne 0 ]; then
    sudo "$@"
  else
    "$@"
  fi
}

# Detect Package Manager and Install
if command -v apt-get &> /dev/null; then
  # Debian, Ubuntu, Kali, Mint, Pop!_OS
  echo -e "System detected: \033[1;32mDebian/Ubuntu based\033[0m"
  echo "Updating package lists..."
  run_priv apt-get update -y
  echo "Installing: $PACKAGES"
  run_priv apt-get install -y $PACKAGES
elif command -v dnf &> /dev/null; then
  # Fedora, RHEL 8+, CentOS 8+
  echo -e "System detected: \033[1;32mRedHat/Fedora based (dnf)\033[0m"
  echo "Installing: $PACKAGES"
  run_priv dnf install -y $PACKAGES
elif command -v pacman &> /dev/null; then
  # Arch Linux, Manjaro, EndeavourOS
  echo -e "System detected: \033[1;32mArch Linux based\033[0m"
  echo "Installing: $PACKAGES"
  # -S: Sync/Install, --noconfirm: automatic yes, --needed: skip if up to date
  run_priv pacman -S --noconfirm --needed $PACKAGES
elif command -v zypper &> /dev/null; then
  # openSUSE
  echo -e "System detected: \033[1;32mopenSUSE\033[0m"
  echo "Installing: $PACKAGES"
  run_priv zypper install -n $PACKAGES
elif command -v yum &> /dev/null; then
  # Older RHEL, CentOS 7, Amazon Linux
  echo -e "System detected: \033[1;32mLegacy RedHat/CentOS (yum)\033[0m"
  echo "Installing: $PACKAGES"
  run_priv yum install -y $PACKAGES
elif command -v apk &> /dev/null; then
  # Alpine Linux
  echo -e "System detected: \033[1;32mAlpine Linux\033[0m"
  echo "Installing: $PACKAGES"
  run_priv apk add --no-cache $PACKAGES
elif command -v xbps-install &> /dev/null; then
  # Void Linux
  echo -e "System detected: \033[1;32mVoid Linux\033[0m"
  echo "Installing: $PACKAGES"
  run_priv xbps-install -Sy $PACKAGES
else
  echo -e "\033[1;31mError: Compatible package manager not found.\033[0m"
  echo "Supported managers: apt, dnf, pacman, zypper, yum, apk, xbps"
  exit 1
fi

# Check if the previous command was successful
if [ $? -eq 0 ]; then
  echo -e "\033[1;32m\nSuccess! Installation complete.\033[0m"
else
  echo -e "\033[1;31m\nInstallation failed.\033[0m"
  echo "Possible reasons:"
  echo "1. The package name differs on this distribution."
  echo "2. You do not have internet access."
  echo "3. The package does not exist in your repositories."
fi
