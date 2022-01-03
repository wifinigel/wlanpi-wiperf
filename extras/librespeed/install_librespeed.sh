#!/usr/bin/env bash

# manual Librespeed installation for WLANPi RPi edition

set -e

if [ $EUID -ne 0 ]; then
   echo "This script must be run as root (e.g. use 'sudo')" 
   exit 1
fi

# Check we're connected to the Internet
echo "* Checking Internet connection..."
if ping -q -w 1 -c 1 google.com > /dev/null; then
  echo "* Connected."
else
  echo "* We do not appear to be connected to the Internet (I can't ping Google.com), exiting."
  exit 1
fi

# get machine (e.g. armv7l)
MACHINE=$(uname -m)

# filter machine type to std format
case $MACHINE in
  armv7* ) MACHINE=armv7;;
  armv6* ) MACHINE=armv6;;
  armv5* ) MACHINE=armv5;;
  armv6* ) MACHINE=armv6;;
  arm64* ) MACHINE=arm64;;
  amd64* ) MACHINE=amd64;;
  *      ) echo "* Unknown machine type: $MACHINE, unable to proceed"; exit 1;;
esac

# binary download URL
DOWNLOAD_URL="https://github.com/librespeed/speedtest-cli/releases/download/v1.0.9/librespeed-cli_1.0.9_linux_$MACHINE.tar.gz"

# installation folder for Librespeed binary
BINARY_DEST=/usr/local/bin/

##############################
# Perform download & install
##############################

echo "* Downloading Librespeed..."
cd /tmp
wget $DOWNLOAD_URL

# extract the files from downloaded archive
echo "* Extracting Librespeed..."
tar xvzf "librespeed-cli_1.0.9_linux_$MACHINE.tar.gz"

# change the owner of the cli utility to root
echo "* Setting Librespeed file ownership..."
sudo chown root:root ./librespeed-cli

# copy the cli utility to its final destination

echo "* Copying Librespeed binary to final destination ($BINARY_DEST)..."
sudo cp ./librespeed-cli $BINARY_DEST

# verify librespeed cli is ready to go
echo "* Checking Librespeed ready to go (getting version info):"
librespeed-cli --version

echo "* Librespeed install complete."
