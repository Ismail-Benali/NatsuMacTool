#!/bin/bash
if [ "$EUID" -ne 0 ]; then
    echo "[-] Please run as root (sudo ./install.sh)"
    exit 1
fi

echo "[*] Installing NatsuMacTool system-wide..."
cp NatsuMacTool.sh /usr/local/bin/natsumactool
chmod +x /usr/local/bin/natsumactool

cp natsumactool.service /etc/systemd/system/natsumactool.service
systemctl daemon-reload
systemctl enable natsumactool.service

echo "[+] Installation complete! You can now use 'natsumactool' from anywhere."
echo "[+] Service enabled to run on system startup."
