#!/usr/bin/env bash
#####################################################
#
# Quickstart script to get wiperf up and running 
# for demos, labs etc.
#
# Note: the script assumes we are using wlan0
#
#####################################################
if [ $EUID -ne 0 ]; then
   echo "This script must be run as root (e.g. use 'sudo')" 
   exit 1
fi

set -e

SECURITY_TYPE=""
SSID=""
PSK=""
USERNAME=""
PWD=""
INTERACE="wlan0"
SUPPLICANT_FILE=/etc/wlanpi-wiperf/etc/wpa_supplicant/wpa_supplicant.conf
STATUS_FILE="/etc/wlanpi-state"

# get architecture type (armhf, arm64)
ARCH=$(dpkg --print-architecture)
# get codename (buster, bullseye)
CODENAME=$(cat /etc/os-release | grep VERSION_CODENAME | cut -d"=" -f2)
# get machine (armv7l)
MACHINE=$(uname -m)


get_ssid () {
    read -p "* Please enter the SSID of the network : " SSID
    return
}

get_psk () {
    # prompt for psk 
    read -p "* Enter the network key : " PSK
    return
}

get_peap () {
    # prompt for username/pwd
    read -p "* Enter the PEAP userame : " USERNAME
    read -p "* Enter the PEAP password : " PWD
    return
}

get_security_type () {
    read -p "* Enter security type (psk or peap): " SECURITY_TYPE

    case $SECURITY_TYPE in
        psk|PSK   ) get_psk;;
        peap|PEAP ) get_peap;;
        *         ) echo "* Option ($SECURITY_TYPE) not recognised. Exiting."; exit 1;
    esac

    return
}

config_psk () {
    # write a new supplicant file with PSK config

    # check if supplicant file exists, back it up
    if [ -e "$SUPPLICANT_FILE" ] ; then
        cp $SUPPLICANT_FILE "$SUPPLICANT_FILE.bak"
    fi

cat <<PSK > $SUPPLICANT_FILE
network={
  ssid="$SSID"
  psk="$PSK"
}
PSK

    return
}

config_peap () {
    # write a new supplicant file with PEAP config

    # check if supplicant file exists, back it up
    if [ -e "$SUPPLICANT_FILE" ] ; then
        cp $SUPPLICANT_FILE "$SUPPLICANT_FILE.bak"
    fi

    cat <<PSK > $SUPPLICANT_FILE
network={
  ssid="$SSID"
  key_mgmt=WPA-EAP
  eap=PEAP
  anonymous_identity="anonymous"
  identity="$USERNAME"
  password="$PWD"
  phase2="autheap=MSCHAPV2"
}
PSK

    return
}

config_wireless () {

    # set up the wireless connection configuration
    clear
    cat <<WIRELESS_INTRO
#####################################################

                Wireless Configuration

We will now configure the wireless connection on this
probe for WPA2/PSK or WPA2/PEAP. 

Please ensure you have the name of the SSID that 
you would like the probe to connect to. Also ensure
that you have credentials for the network (i.e. the
shared key or user/pwd)

##################################################### 
WIRELESS_INTRO

    read -p "* Do you wish to configure the wireless connection? (y/n) : " yn

    if [[ ! $yn =~ [yY] ]]; then
        echo "* OK, moving to next task."
        return
    fi

    # Select PSK or PEAP
    clear
    cat <<SEC
#####################################################

               Wireless Configuration

Please enter the SSID of the chosen network and choose
the security method to connect to the network:

    WPA/PSK = PSK
    WPA/PEAP = PEAP

##################################################### 
SEC

    get_ssid
    get_security_type

    case $SECURITY_TYPE in
        psk|PSK   ) config_psk;;
        peap|PEAP ) config_peap;;
        *         ) echo "* Option ($SECURITY_TYPE) not recognised. Exiting."; exit 1;
    esac

    echo "Wireless configured."
    return
} 


#####################################################

main () {

  # check that the WLAN Pi is in classic mode
  PI_STATUS=`cat $STATUS_FILE | grep 'classic'` || true
  if  [ -z "$PI_STATUS" ]; then
     cat <<FAIL
####################################################
Failed: WLAN Pi is not in classic mode.

Please switch to classic mode and re-run this script

(exiting...)
#################################################### 
FAIL
     exit 1
  fi

     clear
     cat <<INTRO
#####################################################

               Quickstart Configuration

This wizard utility provides the option to configure
the following areas of the wiperf probe to get you 
going quickly:

 1. Wireless configuration
 2. Librespeed installation
 3. Grafana installation

Each configuration section is optional. We will now
proceed with the configuration wizard:

##################################################### 
INTRO

    read -p "* Do you wish to continue with this wizard? (y/n) : " yn

    if [[ ! $yn =~ [yY] ]]; then
        echo "* OK, you can re-run this script at a later time, exiting."
        exit 1
    fi

    config_wireless

    sleep 2
    clear
    cat <<LIBRESPEED
#####################################################

               Librespeed Installation

By defaut, wiperf will perform speedtests using the
Ookla speedtest service. However, you may also use 
the Librespeed service as an alternative. Librespeed
does not provide a standardized installation package,
therefore it has to be installed manually. 

This script can install Librespeed for you to make
things a little easier.

If you would like to install Librespeed, please 
indicate below. Note that this process requires that
the probe is connected to the Internet

##################################################### 
LIBRESPEED

    read -p "Would to like to install Librespeed on this probe (y/n) : " yn

    case $yn in
        y|Y ) echo "* installing Librespeed..." ;
              cd /opt/wlanpi-wiperf/extras/librespeed ;
              ./install_librespeed.sh;;
        *   ) echo "* Librespeed installation not selected. Moving to next task.";;
    esac

    sleep 2
    clear
    cat <<GRAFANA
#####################################################

               Grafana Installation

It is generally recommended to send data from a
wiperf probe to a central Grafana server. However, 
it is possible to install Grafana locally on the probe
and views reports directly on the probe itself.

If you would like to install Grafana, please 
indicate below. Note that this process will take
several minutes to complete and requires the probe
is connected to the Internet

##################################################### 
GRAFANA

    read -p "* Would to like to install Grafana on this probe (y/n) : " yn

    case $yn in
        y|Y ) echo "* installing Grafana...";;
        *   ) echo "* Grafana installation not selected. We're all done. Bye!"; exit 0;
    esac

    cd /opt/wlanpi-wiperf/extras/grafana
    ./install_grafana.sh

    cat <<COMPLETE


#####################################################

 Quickstart script completed. If the script completed
 with no errors, you may now switch in to wiperf
 mode.

 Would you like me to switch your WLAN Pi in to
 wiperf mode (this will cause a reboot?

##################################################### 
COMPLETE
    
    read -p "* Would to like switch to wiperf mode? (y/n) : " yn

    case $yn in
        y|Y ) echo "* Switching...";;
        *   ) echo "* OK, you can switch to wiperf mode later using the front panel buttons. We're all done. Bye!"; exit 0;
    esac

    echo "* (After a reboot, the WAN Pi will come back up in wiperf mode.)"
    /usr/sbin/wiperf_switcher on

    return
}

########################
# main
########################
main
exit 0

