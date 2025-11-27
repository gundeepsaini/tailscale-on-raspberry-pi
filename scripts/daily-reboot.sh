#!/bin/bash
set -e

echo "0 6 * * * root /sbin/shutdown -r now" | sudo tee /etc/cron.d/daily-reboot

echo "Daily reboot scheduled at 6 AM."
