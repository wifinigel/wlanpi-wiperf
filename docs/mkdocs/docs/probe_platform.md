Title: Probe Platform
Authors: Nigel Bowden

# Probe Platform

Wiperf has been primarily designed to work on the Pro version of the WLAN Pi platform. It is baked in to the image of the WLAN Pi and can be activated by switching in to wiperf mode on the WLAN Pi. 

## Raspberry Pi

![RPi](images/rpi.png)

Wiperf is intended to run on other platforms that support the Raspberry Pi OS. This should include off-the-shelf RPI4 boards. The full details of how wiperf will be installed and used on the RPI platform will be announced in due course.

# Probe Preparation

The wiperf probe needs to have a few pre-requisite activities completed prior to using the WLAN Pi as a Wiperf probe. 

## Software Image
It is always best to ensure you have the latest version of the Wiperf image installed on your WLAN Pi. To check for software updates, run the following CLI update command while the WLAN Pi is in "classic" mode and is connected to the Internet:

```
sudo apt update
sudo apt upgrade wlanpi-wiperf
```

## Probe CLI Access
To perform some of the required probe configuration activities, CLI access to the WLAN Pi is needed. The easiest way to achieve this is to SSH to the probe over an OTG connection, or plug the WLAN Pi in to an ethernet network port and SSH to its DHCP assigned IP address (shown on the front panel). Visit the WLAN Pi documentation site for more details of how to gain access to the WLAN Pi: [link](https://wlan-pi.github.io/wlanpi-documentation/){target=_blank}

## Hostname Configuration
By default, the hostname of your WLAN Pi is : `wlanpi`. It is strongly advised to change its hostname if you have several probes reporting in to the same data server. If all use the same hostname, there will be no way of distinguishing data between devices. 

*(Note that if you decide to skip this step and subsequently change the hostname, historical data from the probe will not be associated with the data sent with the new hostname in your data server)*

If you'd like to change to a more meaningful hostname, then you will need to SSH to your WLAN Pi and update the `/etc/hostname` and `/etc/hosts` files, followed by a reboot of the WLAN Pi:

Edit the /etc/hostname file using the command:

```
sudo nano /etc/hostname
```

There is a single line that says 'wlanpi'. Change this to your required hostname. Then hit Ctrl-X  and "y" to save your changes.

Next, edit the /etc/hosts file:

```
sudo nano /etc/hosts
```
Change each instance of 'wlanpi' to the new hostname (there are usually two instances). Then hit Ctrl-X  and "y" to save your changes.

Finally, reboot your WLAN Pi:

```
sudo reboot
```
## Network Connectivity

### Ethernet
If the probe is to be connected to Ethernet only, then there is no additional configuration required. By default, if a switch port that can supply a DHCP address is used, the probe will have the required network connectivity.

### Wireless Configuration (wpa_supplicant.conf)
If wiperf is running in wireless mode, when the WLAN Pi is flipped in to wiperf mode, it will need to join the SSID under test to run the configured network tests. We need to provide a configuration (that is only used in wiperf mode) to allow the WLAN Pi to join a WLAN.

Edit the following file with the configuration and credentials that will be used by the WLAN Pi to join the SSID under test once it is switched in to wiperf mode:

```
cd /etc/wlanpi-wiperf/conf/etc/wpa_supplicant
sudo nano ./wpa_supplicant.conf
```

There are a number of sample configurations included in the default file provided (PSK, PEAP & Open auth). Uncomment the required section and add in the correct SSID & authentication details. (For EAP-TLS, it's time to check-out Google as I've not had opportunity to figure that scenario out...)

(__Note:__ *This wireless configuration is only used when the WLAN Pi is flipped in to wiperf mode, not for standard (classic mode) wireless connectivity*)

!!! Note
    If you'd like to fix the AP that the probe associates with, check out [this note](adv_fixed_bssid.md)

At this point, the pre-requisite activities for the WLAN Pi are complete. Next, move on to the [probe configuration](probe_configure.md).
