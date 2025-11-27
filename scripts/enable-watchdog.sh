#!/bin/bash
set -e

echo "=== Enabling watchdog ==="

# Enable watchdog kernel module
echo "bcm2835_wdt" | sudo tee -a /etc/modules-load.d/watchdog.conf

# Enable systemd watchdog
sudo bash -c 'cat > /etc/systemd/system.conf.d/override-watchdog.conf <<EOF
[Manager]
RuntimeWatchdogSec=20s
ShutdownWatchdogSec=10min
EOF'

# Enable auto-restart for key services
for svc in ssh tailscaled; do
  sudo systemctl edit $svc <<EOF
[Service]
Restart=always
RestartSec=5
EOF
done

sudo systemctl daemon-reload
echo "Watchdog enabled and services configured to auto-restart."
