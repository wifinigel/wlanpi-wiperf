# Setup Commands

## Install wiperf on WLAN Pi
```
# install pre-req packages
sudo apt-get update
sudo apt-get install python3-pip iperf3 git curl netcat librespeed-cli -y
sudo reboot

# install wiperf itself
curl -s https://raw.githubusercontent.com/wifinigel/wiperf2/main/setup.sh | sudo bash -s install wlanpi
```

## Remove wiperf
```
# remove wiperf
curl -s https://raw.githubusercontent.com/wifinigel/wiperf2/main/setup.sh | sudo bash -s remove wlanpi
```