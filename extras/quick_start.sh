#####################################################
#
# Quickstart script to get wiperf up and running 
# for demos, labs etc.
#
#####################################################

SECURITY_TYPE=""
SSID=""
PSK=""
USERNAME=""
PWD=""
INTERACE=""

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
        psk  ) get_psk;;
        PSK  ) get_psk;;
        peap ) get_peap;;
        PEAP ) get_peap;;
        *    ) echo "Option ($SECURITY_TYPE) not recognised. Exiting."; exit 1;
    esac

    return
}

config_psk () {
    # configure psk file here
    # TODO
    echo ""
}

config_peap () {
    # configure peap file here
    # TODO
    echo ""
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
        psk  ) config_psk;;
        PSK  ) config_psk;;
        peap ) config_peap;;
        PEAP ) config_peap;;
        *    ) echo "Option ($SECURITY_TYPE) not recognised. Exiting."; exit1;
    esac
}

########################
# main
########################

main

exit 0




# Install local Influx/Grafana?
