#!/bin/bash

# Update package list and upgrade packages
apt update -y
apt upgrade -y

# Check if a reboot is required
if [ -f /var/run/reboot-required ]; then
  echo "Reboot required. Restarting the server."
  sudo reboot
else
  echo "No reboot required."
fi
