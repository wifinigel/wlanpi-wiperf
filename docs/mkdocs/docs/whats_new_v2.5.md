Title: What's New in version 2.5
Authors: Nigel Bowden

# What's New in version 2.5
![wiperf_logo](images/wiperf_logo.png){ align=right }

<span style="font-size: small; color:gray">*03rd January 2022 - Author: Nigel Bowden*</span><br><br>
Version 2.5 marks a significant step in the evolution of the Wiperf UX utility. In this release, the entire codebase has been moved under the umbrella of the WLAN Pi project. 

The WLAN Pi platform will be the primary platform upon which Wiperf will be supported going forwards, though support for running wiperf on a vanilla Raspberry Pi platform will be supported as far as it practically possible. Details of support on the RPi are still under review and development.

In this release, there are significant under the hood changes that will provide a more reliable and supportable code base going forwards. The main change is that the Wiperf code is now provided as a single Debian package that can be installed and upgraded using the usual `apt install` and `apt upgrade` commands that are used in Debian-style distributions.

In addition, the code is now installed as a Linux service, removing the need for cron jobs that were previously used for scheduling test poll cycles.

Version 2.5 is also bundled with a CLI quick start script that can be used to get you up and going with Wiperf quickly so that you ca kick the tyres on Wiperf without wading through lots of documentation.

## Reporting Platform support
Previous releases of Wiperf have provided support for both Splunk and InfluxDB/Grafana as reporting platforms. From v2.5, and going forwards, data export for both platforms will be provided, but the provision of dashboard templates and testing against the Splunk platform is removed. 

Full support will be retained for InfluxDB/Grafana. The reason for this move is that the support and development burden for two reporting platforms provides too much of an overhead and impacts progress of developing the overall Wiperf project. As mentioned previously, data may still be exported to Splunk using the Wiperf exporter, but it will be up to end users to develop their own reporting dashboards. 

(__Note: Documentation for releases v2.2 and before may still be accessed at : https://wifinigel.github.io/wiperf/. This contains details of Splunk templates and installation for those who wish to continue to use Splunk__)

## RPi Support
Wiperf has always been supported on both the WLAN Pi and RPi platforms. As with the reporting platforms mentioned above, maintaining support for both platforms has been a significant burden that has impeded development of the project. With the move of the WLAN Pi platform to a distribution based upon Raspberry OS, the intention is to support both the WLAN Pi and RPI from a common package that will run on both platforms.

This new release of Wiperf initially supports only the new WLAN Pi platform, but the intention is to release an updated package that will run on both the WLAN Pi and RPi. Details will be released in the near future. 

## Quickstart Support

