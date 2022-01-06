Title: Probe Software Upgrade
Authors: Nigel Bowden

# Probe Software Upgrade
Periodically, new versions of Wiperf code may be available to add bug-fixes and new features. The Wiperf code must be upgraded from the CLI of the probe.

To check if any new version of Wiperf software are available, perform the following commands on the CLI of the WLAN Pi. Note that the WLAN Pi must be able to access the Internet and must be running in "classic" mode:

```
# get latest updates
sudo apt update

# check if there is an update of Wiperf available
apt list --upgradeable | grep wiperf

# if an update is shown, then upgrade using this command
apt upgrade wlanpi-wiperf

```

Although not mandated, a reboot of the WLAN Pi is probably advisable after updating any packages.