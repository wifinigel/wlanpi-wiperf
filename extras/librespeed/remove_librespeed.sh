#!/usr/bin/env bash

# manual Librespeed removal for WLANPi RPi edition

set -e

if [ $EUID -ne 0 ]; then
   echo "This script must be run as root (e.g. use 'sudo')" 
   exit 1
fi

# installation folder for Librespeed binary
BINARY_DEST=/usr/local/bin/

##############################
# remove binary
##############################
echo "* Removing Librespeed..."
rm "${BINARY_DEST}librespeed-cli"

echo "* Librespeed removal complete."
