#!/bin/bash
set -e

echo "=== Enabling watchdog ==="

# Enable watchdog kernel module at boot
echo "bcm2835_wdt" | sudo tee /etc/modules-load.d/watchdog.conf

# Create directory if missing
sudo mkdir -p /etc/systemd/system.conf.d

# Enable systemd watchdog timers
sudo bash -c 'cat > /etc/systemd/system.conf.d/override-watchdog.conf <<EOF
[Manager]
RuntimeWatchdogSec=20s
ShutdownWatchdogSec=10min
EOF'

# Enable auto-restart for important services
for svc in ssh tailscaled; do
sudo mkdir -p /etc/systemd/system/${svc}.service.d
sudo bash -c "cat > /etc/systemd/system/${svc}.service.d/restart.conf <<EOF
[Service]
Restart=always
RestartSec=5
EOF"
done

# Reload systemd
sudo systemctl daemon-reload

echo "Watchdog enabled and auto-restart configured."
