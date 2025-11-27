#!/bin/bash
set -e

echo "=== Reducing SD card writes ==="

# 1. Move /tmp and /var/tmp to RAM
sudo bash -c 'cat > /etc/tmpfiles.d/ram-tmp.conf <<EOF
# Keep tmp in RAM
D! /tmp 1777 root root -
D! /var/tmp 1777 root root -
EOF'

# 2. Enable journaling rate limits & reduce persistent logs
sudo sed -i 's/#Storage=.*/Storage=volatile/' /etc/systemd/journald.conf
sudo sed -i 's/#RuntimeMaxUse=.*/RuntimeMaxUse=50M/' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald

# 3. Reduce swap usage (so SD card isn’t hit frequently)
sudo sed -i 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=100/' /etc/dphys-swapfile
sudo systemctl restart dphys-swapfile || true

echo "Done. Reboot recommended."
