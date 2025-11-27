#!/bin/bash
set -e

echo "=== Add a new Wi-Fi network ==="

# Ask for SSID
read -p "Enter Wi-Fi SSID: " SSID
if [ -z "$SSID" ]; then
  echo "SSID cannot be empty."
  exit 1
fi

# Ask for Wi-Fi password (hidden input)
read -s -p "Enter Wi-Fi Password: " PASS
echo
if [ -z "$PASS" ]; then
  echo "Password cannot be empty."
  exit 1
fi

echo "Adding WiFi network: $SSID"

sudo bash -c "cat >> /etc/wpa_supplicant/wpa_supplicant.conf <<EOF

network={
    ssid=\"$SSID\"
    psk=\"$PASS\"
    key_mgmt=WPA-PSK
    priority=1
}
EOF"

# Ask wpa_supplicant to reload config
sudo wpa_cli -i wlan0 reconfigure || echo "WiFi will connect on next boot."

echo "Done. New WiFi network added."
