#!/bin/bash
set -e

echo "=== Configuring firewall for LAN + Tailscale SSH only ==="

sudo apt-get install -y ufw

# Reset firewall
sudo ufw --force reset

# Default rules
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH ONLY from LAN (192.168.x.x)
sudo ufw allow from 192.168.0.0/16 to any port 22 proto tcp

# Allow Tailscale interface (for SSH + exit-node traffic)
sudo ufw allow in on tailscale0
sudo ufw allow out on tailscale0

# Allow forwarded traffic for exit node (tailscale0 -> LAN/WAN)
sudo ufw route allow in on tailscale0 out on eth0
sudo ufw route allow in on tailscale0 out on wlan0

sudo ufw --force enable

echo "Firewall locked down:
- SSH only from LAN + Tailscale
- All other inbound traffic blocked
- Exit node forwarding preserved"
