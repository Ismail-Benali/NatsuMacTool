![NatsuMacTool Banner](https://github.com/Ismail-Benali/NatsuMacTool/assets/90980178/a0d62156-77ad-4708-85e1-5066e1686a32)

# 🛡️ NatsuMacTool v2.0.0

**A secure, robust, and production-ready Bash script for MAC address randomization on Linux.**

[![Release](https://img.shields.io/github/v/release/Ismail-Benali/NatsuMacTool?style=flat-square&color=blue)](https://github.com/Ismail-Benali/NatsuMacTool/releases) [![License](https://img.shields.io/github/license/Ismail-Benali/NatsuMacTool?style=flat-square&color=green)](https://github.com/Ismail-Benali/NatsuMacTool/blob/main/LICENSE) ![Bash](https://img.shields.io/badge/Bash-4.0+-green?style=flat-square&logo=gnu-bash) ![Linux](https://img.shields.io/badge/Linux-NetworkManager-blue?style=flat-square&logo=linux)

## 📖 Overview

NatsuMacTool is an advanced Bash script designed to automatically randomize MAC addresses for all active network interfaces (Ethernet and Wi-Fi) using NetworkManager (nmcli).

Originally built as a simple privacy tool, v2.0.0 has been completely rewritten to include LAA-compliant MAC generation, intelligent interface filtering, persistent logging, and a safe dry-run mode—making it highly reliable and suitable for production environments.

## ⚠️ Migrating from v1.x?

The new version uses modern systemd services instead of the deprecated rc.local method. Please refer to the Auto-Start section below for the updated setup.

## ✨ Features

- 🔒 **LAA-Compliant MAC Generation:** Generates valid Locally Administered Addresses (starting with 02) to prevent OUI conflicts and network bans.
- 🎯 **Smart Connection Mapping:** Dynamically finds the correct NetworkManager connection profile, eliminating the "device name ≠ connection name" errors present in older versions.
- 🛡️ **Safety Filters:** Automatically skips loopback and virtual/container interfaces (lo, docker*, virbr*, tun*, veth*, br-*) to prevent breaking system services.
- 🧪 **Dry-Run Mode:** Preview all intended changes safely before applying them to your system (`--dry-run` or `-d`).
- 📝 **Persistent Logging:** All successful changes are logged with timestamps to `/var/log/natsumactool.log` for easy auditing.
- ✅ **Post-Change Verification:** Confirms the MAC address was successfully applied and the connection restarted before reporting success.
- ⚡ **Immediate Application:** Restarts the connection profile instantly to apply changes without requiring a system reboot.

## 📋 Prerequisites

| Requirement | Details |
| :--- | :--- |
| OS | Linux distribution using NetworkManager (Ubuntu, Fedora, Arch, Debian, Mint, etc.) |
| Shell | Bash 4.0+ |
| Dependencies | `nmcli` (comes pre-installed with NetworkManager) |
| Privileges | Root access (`sudo`) |

## 🚀 Installation & Usage

### 1. Download the Script

Clone the repository or download the latest release archive:

```bash
git clone https://github.com/Ismail-Benali/NatsuMacTool.git
cd NatsuMacTool
```

### 2. Make it Executable

Grant execution permissions to the script:

```bash
chmod +x NatsuMacTool.sh
```

### 3. Test Safely (Highly Recommended) 🧪

Use the Dry-Run mode to see exactly what the script will do without modifying your actual network configuration:

```bash
sudo ./NatsuMacTool.sh --dry-run
```

### 4. Apply Changes

Run the script with root privileges to randomize MAC addresses immediately:

```bash
sudo ./NatsuMacTool.sh
```

## 🔄 Auto-Start on Boot (systemd)

Modern Linux systems use systemd instead of the deprecated rc.local. To make NatsuMacTool run automatically and reliably on every boot:

### 1. Create a Service File

Open a new service file in your text editor:

```bash
sudo nano /etc/systemd/system/natsumactool.service
```

### 2. Add the Configuration

Paste the following configuration into the file. (Make sure to replace `/path/to/NatsuMacTool.sh` with the actual absolute path to your script, e.g., `/home/user/NatsuMacTool/NatsuMacTool.sh`):

```ini
[Unit]
Description=NatsuMacTool MAC Randomizer
After=NetworkManager.service

[Service]
Type=oneshot
ExecStart=/path/to/NatsuMacTool.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Save the file and exit the editor (`Ctrl+O`, `Enter`, `Ctrl+X` in Nano).

### 3. Enable and Start the Service

Reload the systemd daemon, enable the service to start on boot, and start it immediately:

```bash
sudo systemctl daemon-reload
sudo systemctl enable natsumactool.service
sudo systemctl start natsumactool.service
```

💡 You can verify it is running correctly with:

```bash
sudo systemctl status natsumactool.service
```

## 📊 Log File

All successful MAC address changes are recorded in a dedicated log file:

```text
/var/log/natsumactool.log
```

You can view the history of changes at any time using:

```bash
sudo cat /var/log/natsumactool.log

# Or to follow it in real-time:
sudo tail -f /var/log/natsumactool.log
```

## ❓ Troubleshooting

| Issue | Solution |
| :--- | :--- |
| `nmcli: command not found` | Install NetworkManager: `sudo apt install network-manager` (Debian/Ubuntu) or `sudo dnf install NetworkManager` (Fedora). |
| Script fails silently | Ensure you are running the script with `sudo`. Check `/var/log/natsumactool.log` for specific error details. |
| MAC doesn't change after reboot | Verify the systemd service is enabled and active: `systemctl status natsumactool`. |
| Internet connection drops | Ensure your Wi-Fi password is saved in the NetworkManager profile, as restarting the connection requires re-authentication. |

## 🤝 Contributing

Contributions, issues, and feature requests are highly welcome! Feel free to:

- 🐛 Report bugs or unexpected behavior.
- 💡 Suggest new features (e.g., support for systemd-networkd or iwd).
- 📚 Improve documentation or translate it into other languages.

Please open an Issue or submit a Pull Request.

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

Made with ❤️ by [Ismail Benali](https://github.com/Ismail-Benali)
