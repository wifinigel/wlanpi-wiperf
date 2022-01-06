Title: Grafana Installation
Authors: Nigel Bowden

# Grafana Installation
![grafana_logo](images/grafana_logo.png){ align=right }
Obtaining and installing the Grafana software is straightforward. The following notes provide a high level overview of the steps required. Note that these instructions are for Grafana version 8.3.3 (other versions may work, but have not been tested):  


- Visit the Grafana v8.3.3 installation guide at [https://grafana.com/docs/grafana/v8.3/](https://grafana.com/docs/grafana/v8.3/){target=_blank}. This provides access to a wide variety of information about Grafanam including supported OS'es and platform concepts
- To download the code and to see the commands required for installation on the server CLI, visit the following download page: [https://grafana.com/grafana/download](https://grafana.com/grafana/download){target=_blank}
    - Select the required version (v8.3.3), Open Source edition and OS type ARM (Ubuntu and Debian(ARMv7))
    - Make a copy of the CLI commands provided to download and install the software for your OS
    ```
    sudo apt-get install -y adduser libfontconfig1
    wget https://dl.grafana.com/enterprise/release/grafana-enterprise_8.3.3_armhf.deb
    sudo dpkg -i grafana-enterprise_8.3.3_armhf.deb
    ```
- SSH to the server that will be used to host Grafana
- Make sure your server has Internet connectivity (as it will need to pull down the required software)
- On the CLI of your server, paste in the copied commands to kick-off the software download & install
- Once installation is complete, start the Grafana processes with the server CLI command: `sudo systemctl start grafana-server`
- Ensure that the service will be started in the server is rebooted with: `sudo systemctl enable grafana-server`
- Check the software is installed and running by executing the following command on the server CLI: `sudo systemctl status grafana-server` (ensure the process is "active (running)" )

As a final check, ensure that the Grafana web GUI is available using the URL: http://&lt;server_IP&gt;:3000/ (Note that the default login/pwd is admin/admin)

