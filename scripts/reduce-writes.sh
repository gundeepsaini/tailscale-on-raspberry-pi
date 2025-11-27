#!/bin/bash
set -e

echo "=== Reducing SD card writes ==="

#
# 1. Move /tmp and /var/tmp to RAM
#
sudo bash -c 'cat > /etc/tmpfiles.d/ram-tmp.conf <<EOF
# Keep tmp in RAM
D! /tmp 1777 root root -
D! /var/tmp 1777 root root -
EOF'

#
# 2. Make journald logs volatile (stored in RAM)
#
sudo sed -i 's/^#\?Storage=.*/Storage=volatile/' /etc/systemd/journald.conf
sudo sed -i 's/^#\?RuntimeMaxUse=.*/RuntimeMaxUse=50M/' /etc/systemd/journald.conf
sudo systemctl restart systemd-journald

#
# 3. Reduce swap usage depending on system
#

# Case A: dphys-swapfile installed (older Raspberry Pi OS)
if [ -f /etc/dphys-swapfile ]; then
  echo "Detected dphys-swapfile. Reducing swap size."
  sudo sed -i 's/CONF_SWAPSIZE=.*/CONF_SWAPSIZE=100/' /etc/dphys-swapfile
  sudo systemctl restart dphys-swapfile || true
fi

# Case B: zram-generator in use (bookworm & later)
if [ -f /usr/lib/systemd/system/zram-generator.service ]; then
  echo "Detected zram-generator. Enabling compressed RAM swap only."

  sudo mkdir -p /etc/systemd/zram-generator.conf.d
  sudo bash -c 'cat > /etc/systemd/zram-generator.conf.d/10-zram.conf <<EOF
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
EOF'

  sudo systemctl daemon-reload
  sudo systemctl restart systemd-zram-setup@zram0.service || true
fi

# Case C: systemd-swap
if systemctl list-unit-files | grep -q systemd-swap; then
  echo "Detected systemd-swap. Adjusting config."
  sudo mkdir -p /etc/systemd/swap.conf.d
  sudo bash -c 'cat > /etc/systemd/swap.conf.d/local.conf <<EOF
[zswap]
enabled=1

[zram]
enabled=1
EOF'
  sudo systemctl restart systemd-swap || true
fi

echo "Done. Reboot recommended."
