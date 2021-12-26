#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from apscheduler.schedulers.blocking import BlockingScheduler
from wiperf.helpers.config import read_local_config
from wiperf.helpers.filelogger import FileLogger
import os

# read in config.ini to get interval & offset
config_file = "/etc/wiperf/config.ini"
log_file = "/var/log/wiperf_agent.log"
error_log_file = "/tmp/wiperf_err.log"

file_logger = FileLogger(log_file, error_log_file)

config_vars = read_local_config(config_file, file_logger)
test_interval = config_vars['test_interval']
test_offset = config_vars['test_offset']

def call_wiperf():
    # Call the wiperf entry point
    os.system("/usr/sbin/wiperf 2>&1 > /var/log/wiperf_runtime.log")


def main():
    # add scheduler & start it based on configured interval & offset
    scheduler = BlockingScheduler(timezone="utc")
    scheduler.add_job(call_wiperf, 'cron', minute=f"{test_offset}-59/{test_interval}")
    scheduler.start()


if __name__ == "__main__":
    main()


