Title: Probe Configuration
Authors: Nigel Bowden

# Probe Configuration
The final step in preparing the probe for deployment is to configure Wiperf to run the tests we'd like to perform. We also need to tell Wiperf where it can find the data collection server that will provide network performance reporting and what test interval to use.

The operation of Wiperf is determined by the contents of a configuration file which can be found at `/etc/wlanpi-wiperf/config.ini`. This file needs to be configured to tell Wiperf:

- where to find its data collection server
- which tests to run
- when to run the tests  

## Configuration File
The operation of wiperf is configured using the file `/etc/wlanpi-wiperf/config.ini` This needs to be created & edited prior to running the wiperf software.

Network tests are initiated on the WLAN Pi by switching to Wiperf mode using the front panel menu system.

By default, the config.ini file does not exist. However, a default template config file (`/etc/wlanpi-wiperf/config.default.ini`) is supplied that can be used as the template to create the `config.ini` file. Here is the suggested workflow to create the required `/etc/wlanpi-wiperf/config.ini` file:

Connect to the CLI of the probe (e.g. via SSH), create a copy of the config template file and edit the newly created configuration file:

```
cd /etc/wlanpi-wiperf
# take a copy of the default configuration file
sudo cp ./config.default.ini ./config.ini
# edit the config file with the required probe settings (ctrl-x to exit the editor)
sudo nano ./config.ini
```

By default, the configuration file is set to run all tests except the iperf and SMB tests (which may or may not suit your needs). However, there is still an additional minimum configuration that must be applied to successfully run tests. This is outlined in the subsections below. Once you've got your probe going, you're likely going to want to spend a little more time customising the configuration file for your environment. In summary you will need to:

* Configure the wiperf global mode of operation (wireless or Ethernet) and the interface parameters that determine how the probe is connected to its network
* Configure the management platform you'll be sending data to
* Configure the tests you'd like to run
* Configure the test-run interval

### Mode/Interface Parameters
The probe can perform its tests over either its wireless interface or ethernet interface. These are known as the 'wireless' or 'ethernet' mode within the `config.ini` file. 

In addition, the probe needs to know which interface should be used to send results data back to the data server. It is possible to perform both tests and send results data over the same interface, or it may be preferable to have tests performed over the wireless interface and return results data over the ethernet interface. The final choice is determined by the environment in to which the probe is deployed.

(*Note: if you choose to use Zerotier for management connectivity, the Zerotier interface is also an available option to carry results data back to the data server*)

The interfaces available in the probe for ethernet and wireless connectivity will generally be `eth0` and `wlan0`. However, these names may vary if additional interfaces are present (e.g. wlan1 for a second wireless NIC).  An option to change the actual names of the interfaces of the probe is available if required.

The relevant section of the config.ini file is shown below for reference (note that lines that start with a semi-colon (;) are comments and are ignored. Blank lines are also ignored.):

```
[General]
; global test mode: 'wireless' or 'ethernet'
; 
; wireless mode: 
;    - test traffic runs over wireless interface
;    - management traffic (i.e. result data) sent over interface specified in mgt_if parameter
; ethernet mode:
;    - test traffic runs over ethernet interface
;    - management traffic (i.e. result data) sent over interface specified in mgt_if parameter
;
probe_mode: wireless

; ------------- ethernet mode parameters ------------
; eth interface name - set this as per the output of an ifconfig command (usually eth0)
eth_if: eth0
; ---------------------------------------------------

; ------------- wireless mode parameters ------------
; wlan interface name - set this as per the output of an iwconfig command (usually wlan0)
wlan_if: wlan0
; ---------------------------------------------------

; -------------mgt interface parameters ------------
; interface name over which mgt traffic is sent (i.e. how we get to our management
; server) - options: wlan0, eth0, ztxxxxxx (ZeroTier), lo (local instance of Influx)
mgt_if: wlan0
; ---------------------------------------------------
```
### Data Server Parameters
Wiperf can send results data to Splunk, InfluxDB v1.x or InfluxDB v2.x data collectors through an exporter module provided for each collector type. The relevant authentication parameters need to be set for the collector in-use in the following sections 
(*note that corresponding authentication parameters also need to be configured on the data collector platform also before sending results data - see here for more info:[InfluxDB](influx_configure.md)*)

In summary, the workflow to configure the data server parameters in the probe configuration file is:

- Set the exporter type (splunk/influxdb/influxdb2)
- In the appropriate platform section (i.e. Splunk, InfluxDB1 or InfluxDB2)
    - configure the server address of the target data server
    - configure data server port details (if defaults changed)
    - configure data server credential and database information

The relevant section of the ```config.ini``` file is shown below:

```
; --------- Common Mgt Platform Params ------- 
; set the data exporter type - current options: splunk, influxdb, influxdb2
exporter_type: influxdb
;
;
; If the mgt platform becomes unavailable, results may be spooled to a local 
; directory for later upload when connectivity is restored.This may be disabled
; for purposes of management traffic bandwidth preservation if required.
;
; Results spooling enabled: yes/no
results_spool_enabled: yes
; Max age of results retained (in minutes)
results_spool_max_age: 60
;
;
; It may be useful to have errors being experienced by the probe reported
; back to the mgt platform to assist with diagnosis. Reporting of probe 
; error messages may be enabled in this section.
;
; Enable reporting of  error messages to mgt platform (yes/no)
error_messages_enabled: yes
# To prevent overwhelming the mgt platform, set max number of messages per poll
error_messages_limit: 5
;
;
; At the end of each poll cycle, a summary of which tests passed/failed may
; be returned to allow reporting. This may be disabled for purposes of
; management traffic bandwidth preservation if required.
poller_reporting_enabled: yes
;
; --------------------------------------------
;
; -------------- Splunk Config ---------------
; IP address (ipv4 or ipv6) or hostname of Splunk host
splunk_host: 
; Splunk collector port (8088 by default)
splunk_port: 8088
; Splunk token to access Splunk server created by Splunk (example token: 84adb9ca-071c-48ad-8aa1-b1903c60310d)
splunk_token: 
;---------------------------------------------
;
;-------------- InFlux1 Config ---------------
; IP address (ipv4 or ipv6) or hostname of InfluxDB host
influx_host: 
; InfluxDb collector port (8086 by default)
influx_port: 8086
influx_ssl: false
influx_username: 
influx_password: 
influx_database: 
;---------------------------------------------
;
;-------------- InFlux2 Config ---------------
; IP address or hostname of InfluxDB2 host
influx2_host: 
; InfluxDB2 collector port (443 by default)
influx2_port: 443
influx2_ssl: false
influx2_token: 
influx2_bucket: 
influx2_org: 
;---------------------------------------------
```

### Network Tests
Note that all network tests are enabled by default, apart from the iperf3 and SMB tests. If there are some tests you'd like to disable (e.g. if you don't want to run HTTP tests), then you'll need to open up the config.ini file and look through each section for the "enabled" parameter for that test and set it to "no". For example, to disable the HTTP tests: 

```
; ====================================================================
;  HTTP tests settings
;  (Changes made in this section will be used in next test cycle
;   and may be made while in Wiperf mode on the WLANPi)
; ====================================================================
[HTTP_test]
; yes = enabled, no = disabled
enabled: no
```

It is very likely that you will want to configure items such as test targets and enable tests that are suitable for your environment. For a full description of the configuration file parameters, please review the following page: [config.ini reference guide](config.ini.md){target=_blank}. 


## Running Regular Tests
Before switching the WLAN Pi in to Wiperf mode to commence running the network tests, we need to review the interval at which tests will run.

The interval configuration can be found in the following section of the `config.ini` file:

```
;----------- Test Interval Info  -------------
; test interval (mins) - how often we want to run the tests (5 is the recommended minimum)
test_interval: 5
; test offset from top of hour (must be less than test interval) - 0 = top of hour, 1 = 1 min after top of hour etc.
test_offset: 1
;---------------------------------------------
```

It is strongly recommended to leave the test interval at the default of 5 minutes. If the interval is shortened, there is a chance that the test cycle will not be completed in time for the next cycle to commence. The test cycle can be safely extended beyond 5 minutes if required.

The `test_offset` field is useful if you have several probes running on your network and only want one probe at a time running tests. You may choose to adjust this prevent tests on different probes overlapping, if required. It is worth leaving the offset value as `1`, as experience has shown that some cyles that run at the `00` or `30` minutes past the hour fail due to background tasks running on the Linux operation system of the probe.

## Initial Probe Testing
Once the the WLAN Pi has been put in to wiperf mode, it's time to check if the probe is working as expected after a couple of poll cycle periods have passed (e.g. 10 minutes)

The easiest way to monitor the operation of the probe is to SSH in to the probe and monitor the output of the log file `/var/log/wiperf_agent.log`. This file is created the first time that wiperf runs. If the file is not created after 5 minutes, then check the log file `/var/log/wiperf_cron.log` for error messages, as something fundamental is wrong with the installation.

To watch the output of `/var/log/wiperf_agent.log` in real-time and view activity as data is collected every 5 minutes, run the following command on the CLI of the probe (note this command will fail if wiperf has not run correctly and the file does not yet exist):

```
tail -f /var/log/wiperf_agent.log
```

Every 5 minutes, new log output will be seen that looks similar to this:

```
2020-07-11 11:47:04,214 - Probe_Log - INFO - *****************************************************
2020-07-11 11:47:04,215 - Probe_Log - INFO -  Starting logging...
2020-07-11 11:47:04,216 - Probe_Log - INFO - *****************************************************
2020-07-11 11:47:04,240 - Probe_Log - INFO - Checking if we use remote cfg file...
2020-07-11 11:47:04,241 - Probe_Log - INFO - No remote cfg file confgured...using current local ini file.
2020-07-11 11:47:04,242 - Probe_Log - INFO - No lock file found. Creating lock file.
2020-07-11 11:47:04,243 - Probe_Log - INFO - ########## Network connection checks ##########
2020-07-11 11:47:05,245 - Probe_Log - INFO - Checking wireless connection is good...(layer 1 &2)
2020-07-11 11:47:05,246 - Probe_Log - INFO -   Checking wireless connection available.
2020-07-11 11:47:05,355 - Probe_Log - INFO - Checking we're connected to the network (layer3)
2020-07-11 11:47:05,356 - Probe_Log - INFO -   Checking we have an IP address.
2020-07-11 11:47:05,379 - Probe_Log - INFO -   Checking we can do a DNS lookup to google.com
2020-07-11 11:47:05,406 - Probe_Log - INFO -   Checking we are going to Internet on correct interface as we are in 'wireless' mode.
2020-07-11 11:47:05,430 - Probe_Log - INFO -   Checked interface route to : 216.58.212.238. Result: 216.58.212.238 via 192.168.0.1 dev wlan0 src 192.168.0.48 uid 0
2020-07-11 11:47:05,431 - Probe_Log - INFO - Checking we can get to the management platform...
2020-07-11 11:47:05,432 - Probe_Log - INFO -   Checking we will send mgt traffic over configured interface 'lo' mode.
2020-07-11 11:47:05,455 - Probe_Log - INFO -   Checked interface route to : 127.0.0.1. Result: local 127.0.0.1 dev lo src 127.0.0.1 uid 0
2020-07-11 11:47:05,456 - Probe_Log - INFO -   Interface mgt interface route looks good.
2020-07-11 11:47:05,457 - Probe_Log - INFO -   Checking port connection to InfluxDB server 127.0.0.1, port: 8086
2020-07-11 11:47:05,484 - Probe_Log - INFO -   Port connection to server 127.0.0.1, port: 8086 checked OK.
2020-07-11 11:47:05,485 - Probe_Log - INFO - ########## Wireless Connection ##########
2020-07-11 11:47:05,486 - Probe_Log - INFO - Wireless connection data: SSID:BNL, BSSID:5C:5B:35:C8:4D:C2, Freq:5.5, Center Freq:5.51, Channel: 100, Channel Width: 40, Tx Phy rate:200.0,             Rx Phy rate:135.0, Tx MCS: 0, Rx MCS: 0, RSSI:-42.0, Tx retries:187, IP address:192.168.0.48
2020-07-11 11:47:05,486 - Probe_Log - INFO - InfluxDB update: wiperf-network, source=Network Tests
2020-07-11 11:47:05,487 - Probe_Log - INFO - Sending data to Influx host: 127.0.0.1, port: 8086, database: wiperf)
2020-07-11 11:47:05,573 - Probe_Log - INFO - Data sent to influx OK
2020-07-11 11:47:05,574 - Probe_Log - INFO - Connection results sent OK.
2020-07-11 11:47:05,595 - Probe_Log - INFO - ########## speedtest ##########
2020-07-11 11:47:05,597 - Probe_Log - INFO - Starting speedtest...
2020-07-11 11:47:06,599 - Probe_Log - INFO -   Checking we are going to Internet on correct interface as we are in 'wireless' mode.
2020-07-11 11:47:06,623 - Probe_Log - INFO -   Checked interface route to : 8.8.8.8. Result: 8.8.8.8 via 192.168.0.1 dev wlan0 src 192.168.0.48 uid 0
2020-07-11 11:47:06,624 - Probe_Log - INFO - Speedtest in progress....please wait.
2020-07-11 11:47:28,761 - Probe_Log - INFO - ping_time: 31, download_rate: 41.56, upload_rate: 9.74, server_name: speedtest-net5.rapidswitch.co.uk:8080
2020-07-11 11:47:28,766 - Probe_Log - INFO - Speedtest ended.
2020-07-11 11:47:28,767 - Probe_Log - INFO - InfluxDB update: wiperf-speedtest, source=Speedtest
2020-07-11 11:47:28,768 - Probe_Log - INFO - Sending data to Influx host: 127.0.0.1, port: 8086, database: wiperf)
2020-07-11 11:47:28,858 - Probe_Log - INFO - Data sent to influx OK
2020-07-11 11:47:28,860 - Probe_Log - INFO - Speedtest results sent OK.
```

The output is quite verbose and detailed, but it will provide a good indication of if ad where Wiperf is having difficulties.

Once wiperf is running with no issues indicated in the logs, then it's time to check for results data on your data collection server. Hopefully, you'll see performance data being recorded over time as the probe runs its tests and sends the results to the data collection server. The next step is to [deploy the probe](probe_deploy.md).