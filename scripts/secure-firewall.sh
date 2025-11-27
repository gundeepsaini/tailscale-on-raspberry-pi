#!/bin/bash
set -e

echo "=== Configuring firewall for LAN + Tailscale SSH only ==="

sudo apt-get install -y ufw

# Reset and deny all incoming connections
sudo ufw --force reset
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH ONLY from 192.168.x.x (any 192.168.* network)
sudo ufw allow from 192.168.0.0/16 to any port 22 proto tcp

# Allow ALL traffic on Tailscale interface (including SSH)
sudo ufw allow in on tailscale0

# Recommended for exit node NAT
sudo ufw allow out on eth0
sudo ufw allow out on wlan0

sudo ufw --force enable

echo "Firewall locked down:
- SSH allowed ONLY from LAN (192.168.x.x) and Tailscale.
- All other inbound traffic blocked."
