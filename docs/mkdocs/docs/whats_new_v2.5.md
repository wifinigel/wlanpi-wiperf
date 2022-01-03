Title: What's New in version 2.5
Authors: Nigel Bowden

# What's New in version 2.5
![wiperf_logo](images/wiperf_logo.png)

<span style="font-size: small; color:gray">*03rd January 2022 - Author: Nigel Bowden*</span><br><br>
Version 2.5 marks a significant step in the evolution of the Wiperf UX utility. In this release, the entire codebase has been moved under the unmbrella of the WLAN Pi project. 

The WLAN Pi platform wil be the primary platform upon which wiperf will be supported going forwards, though support for running wiperf on a vanilla Raspbery Pi platform will be supported as far as it practically possible.

In this release, there are significant under the hood changes that will provide a more reliable and supportable code base going forwards. The main change is that the wiperf code is now provided as a single debian package that can be installed and upgraded using the usual `apt install` and `apt upgrade` commands that are used in debian-style distributions.

In addition, the code is now installed as a Linux service, removing the need for cron jobs that were previously used for scheduling test poll cycles.

Version 2.5 is also bundled with a CLI quickstart script that can be used to get you up and going with wiperf quickly so that you ca kick the tyres on wiperf without wading through lots of documentation.
