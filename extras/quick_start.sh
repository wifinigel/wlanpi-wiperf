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
SUPPLICANT_FILE=/etc/wiperf/etc/wpa_supplicant/wpa_supplicant.conf

get_ssid () {
    read -p "Please enter the SSID of the network : " SSID
    return
}

get_psk () {
    # prompt for psk 
    read -p "Enter the network key : " PSK
    return
}

get_peap () {
    # prompt for username/pwd
    read -p "Enter the PEAP userame : " USERNAME
    read -p "Enter the PEAP password : " PWD
    return
}

get_security_type () {
    read -p "Enter security type : " SECURITY_TYPE

    case $SECURITY_TYPE in
        psk|PSK   ) get_psk;;
        peap|PEAP ) get_peap;;
        *         ) echo "Option ($SECURITY_TYPE) not recognised. Exiting."; exit 1;
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


#####################################################

main () {
    # set up the wireless connection configuration
    clear
    cat <<INTRO
#####################################################

This script will configure your wireless connection
on this probe for WPA2/PSK or WPA2/PEAP. 

Please ensure you have the name of the SSID that 
you would like the probe to connect to. Also ensure
that you have credentials for the network (i.e. the
shared key or user/pwd)

##################################################### 
INTRO

    read -p "Do you wish to continue? (y/n) : " yn

    if [[ ! $yn =~ [yY] ]]; then
        echo "OK, exiting."
        exit 1
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
        *         ) echo "Option ($SECURITY_TYPE) not recognised. Exiting."; exit 1;
    esac

    echo "Wireless configured."
    sleep 2

    clear
    cat <<GRAFANA
#####################################################

               Grafana Installation

It is generally recommended to send data from a
wiperf probe to a central Grafana server. However, 
it is possibe to install Grafana locally on the probe
and report directly from the probe.

If you would like to install Grafana, please 
indicate below. Note that this process will take
several minutes to complete and requires the probe
is connected to the Internet

##################################################### 
GRAFANA

    read -p "Would to like to install Grafana on this probe (y/n) : " yn

    case $yn in
        y|Y ) echo "installing Grafana...";;
        *   ) echo "Grafana installation not selected. We're all done. Bye!"; exit 0;
    esac

    cd /opt/wiperf/extras/grafana
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
    
    read -p "Would to like switch to wiperf mode? (y/n) : " yn

    case $yn in
        y|Y ) echo "Switching...";;
        *   ) echo "OK, you can switch to wiperf mode later using the front panel buttons. We're all done. Bye!"; exit 0;
    esac

    return


}
echo "(After a reboot, the WAN Pi will come back up in wiperf mode.)"
/usr/bin/wiperf_switcher
exit1


########################
# main
########################
main
exit 0

