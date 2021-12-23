#!/usr/bin/env bash

# manual Grafana installation for WLANPi RPi edition

if [ $EUID -ne 0 ]; then
   echo "This script must be run as root (e.g. use 'sudo')" 
   exit 1
fi

set -e

# TODO: add check for Internet conenctivity, otherwise this will fail
# TODO: change to the directory of this script as some action rely on relative paths
# TODO: fix ufw port issue (have to run with ufw disabled at present)

# random pwd generator
rand_pwd() {
  < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-20};echo;
}

# Grafana admin user
GRAFANA_PORT=4000
GRAFANA_USER=wlanpi
GRAFANA_PWD=wlanpi

# Influx DB admin
DB_USER=wlanpi
DB_PWD=$(rand_pwd)

# Influx grafana user
DB_GRAFANA_USER=grafana
DB_GRAFANA_PWD=$(rand_pwd)

# Influx probe user
DB_PROBE_USER=wiperf_probe
DB_PROBE_PWD=$(rand_pwd)

echo ""
echo "* ========================="
echo "* Installing Grafana..."
echo "* ========================="


echo "* Installing pre-req packages."
sudo apt-get install -y adduser libfontconfig1

echo "* Downloading Grafana."
wget https://dl.grafana.com/oss/release/grafana_8.0.5_armhf.deb

echo "* Installing Grafana."
sudo dpkg -i grafana_8.0.5_armhf.deb

# remove requirement to set default admin pwd & change default user/pwd to wlanpi/wlanpi
echo "* Customizing Grafana."
sudo sed -i 's/;disable_initial_admin_creation/disable_initial_admin_creation/g' /etc/grafana/grafana.ini
sudo sed -i 's/;admin_user = admin/admin_user = '"$GRAFANA_USER"'/g' /etc/grafana/grafana.ini
sudo sed -i 's/;admin_password = admin/admin_password = '"$GRAFANA_PWD"'/g' /etc/grafana/grafana.ini

# set grafana to listen on port GRAFANA_PORT
sudo sed -i 's/;http_port = 3000/http_port = '"$GRAFANA_PORT"'/g' /etc/grafana/grafana.ini

# open port on ufw firewall
echo "* Opening FW port for Grafana."
sudo ufw allow in on eth0 to any port ${GRAFANA_PORT}
sudo ufw allow in on wlan0 to any port ${GRAFANA_PORT}
sudo ufw allow in on wlan1 to any port ${GRAFANA_PORT}

# take care of grafana service
echo "* Enabling & starting Grafana service."
sudo systemctl daemon-reload
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

# display status of service
echo "* Grafana service status:"
sudo systemctl status --no-pager -l grafana-server | head -n 10
echo "* Grafana Done."


echo ""
echo "* ========================="
echo "* Installing InfluxDB..."
echo "* ========================="


echo "* Getting InfluxDB code...."

sudo wget -qO- https://repos.influxdata.com/influxdb.key | sudo apt-key add -
echo "deb https://repos.influxdata.com/debian buster stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
sudo apt update

echo "* Installing InfluxDB code...."
sudo apt install influxdb
sudo chown influxdb:influxdb /usr/lib/influxdb/scripts/influxd-systemd-start.sh

echo "* Enabling & starting InfluxDB service."
sudo systemctl unmask influxdb.service
sudo systemctl enable influxdb
sudo systemctl start influxdb

# display status of service
echo "* InfluxDB service status:"
sudo systemctl status --no-pager -l influxdb | head -n 10

echo ""
echo "* ========================="
echo "* Configuring InfluxDB..."
echo "* ========================="

echo "* Creating DB & users..."
# create DB
DB_NAME="wlanpi"
influx -execute "create database $DB_NAME" 
influx -execute "create retention policy wiperf_30_days on wlanpi duration 30d replication 1" -database $DB_NAME

# create DB admin user
influx -execute "create user $DB_USER with password '$DB_PWD' with all privileges"

# create grafana user with read-ony to pull stats
influx -execute "CREATE USER $DB_GRAFANA_USER WITH PASSWORD '$DB_GRAFANA_PWD'"
influx -execute "GRANT read ON $DB_NAME TO $DB_GRAFANA_USER"

# create wiperf probe user with write access
influx -execute "CREATE USER $DB_PROBE_USER WITH PASSWORD '$DB_PROBE_PWD'"
influx -execute "GRANT WRITE ON $DB_NAME TO $DB_PROBE_USER"

# enable DB authentication
sudo sed -i 's/# auth-enabled = false/auth-enabled = true/g' /etc/influxdb/influxdb.conf
sudo systemctl restart influxdb

# add data source to Grafana
echo "* Adding DB as data source to Grafana..."

echo "* Adding DB name & credentials for data source."
sudo sed -i "s/password:.*$/password: \"$DB_GRAFANA_PWD\"/" influx_datasource.yaml
sudo sed -i "s/user:.*$/user: \"$DB_GRAFANA_USER\"/" influx_datasource.yaml
sudo sed -i "s/database:.*$/database: \"$DB_NAME\"/" influx_datasource.yaml

sudo cp influx_datasource.yaml /etc/grafana/provisioning/datasources/

echo "* Restarting grafana."
sudo systemctl restart grafana-server

# add dashboard to Grafana
echo "* Adding dashboards to Grafana..."
sudo cp  /opt/wiperf/dashboards/grafana/*.json /usr/share/grafana/public/dashboards/
sudo cp import_dashboard.yaml /etc/grafana/provisioning/dashboards/
sudo systemctl restart grafana-server

# create probe config.ini file and add influx credentials
CFG_FILE_NAME=/etc/wiperf/config.ini
sudo cp /etc/wiperf/config.default.ini $CFG_FILE_NAME
sudo sed -i "s/mgt_if:.*$/mgt_if: lo/" $CFG_FILE_NAME
sudo sed -i "s/exporter_type:.*$/exporter_type: influxdb/" $CFG_FILE_NAME
sudo sed -i "s/influx_host:.*$/influx_host: 127.0.0.1/" $CFG_FILE_NAME
sudo sed -i "s/influx_username:.*$/influx_username: $DB_PROBE_USER/" $CFG_FILE_NAME
sudo sed -i "s/influx_password:.*$/influx_password: $DB_PROBE_PWD/" $CFG_FILE_NAME
sudo sed -i "s/influx_database:.*$/influx_database: $DB_NAME/" $CFG_FILE_NAME

# setup a cron job to run the probe
echo "* adding crontab job to start polling..."
if crontab -l | grep wiperf; then
  echo "* Looks like we already have a probe cron job. Nothing added."
else 
  # add probe polling job
  TMP_CRON_FILE=cron.tmp
  crontab -l > $TMP_CRON_FILE
  echo "*/1 * * * * python3 /opt/wiperf/wiperf_run.py" >> $TMP_CRON_FILE
  crontab $TMP_CRON_FILE
  rm $TMP_CRON_FILE
fi
echo "Cron jobs:"
crontab -u wlanpi -l
echo "* Done."

echo ""
echo "* ================================================"
echo "* Browse Grafana at: http://$(hostname -I | cut -d" " -f1):${GRAFANA_PORT}/ (user/pwd=$GRAFANA_USER/$GRAFANA_PWD)"
echo "* ================================================"
echo ""
echo ""
