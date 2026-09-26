#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "[-] Please run as root (sudo ./install.sh)"
    exit 1
fi

echo "[*] Installing NatsuMacTool v2.2.0 system-wide..."

# 1. Install main script
cp NatsuMacTool.sh /usr/local/bin/natsumactool
chmod +x /usr/local/bin/natsumactool

# 2. Install config file (don't overwrite if already exists)
if [ ! -f /etc/natsumactool.conf ]; then
    cp natsumactool.conf /etc/natsumactool.conf
    echo "[+] Installed default configuration to /etc/natsumactool.conf"
else
    echo "[*] Existing /etc/natsumactool.conf found. Keeping your settings."
fi

# 3. Install systemd service
cp natsumactool.service /etc/systemd/system/natsumactool.service
systemctl daemon-reload
systemctl enable natsumactool.service

# 4. Install NM Dispatcher script (optional auto-trigger on network up)
if [ -d /etc/NetworkManager/dispatcher.d ]; then
    cp natsumactool-dispatcher.sh /etc/NetworkManager/dispatcher.d/99-natsumactool
    chmod +x /etc/NetworkManager/dispatcher.d/99-natsumactool
    echo "[+] Installed NetworkManager dispatcher hook."
fi

echo "[+]. Installation complete! Use 'natsumactool --status' to check interfaces."
