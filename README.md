![NatsuMacTool Banner](https://github.com/Ismail-Benali/NatsuMacTool/assets/90980178/a0d62156-77ad-4708-85e1-5066e1686a32)

# 🛡️ NatsuMacTool v2.1.0

**A secure, robust, and production-ready Bash script for MAC address randomization and management on Linux.**

[![Release](https://img.shields.io/github/v/release/Ismail-Benali/NatsuMacTool?style=flat-square&color=blue)](https://github.com/Ismail-Benali/NatsuMacTool/releases) [![License](https://img.shields.io/github/license/Ismail-Benali/NatsuMacTool?style=flat-square&color=green)](https://github.com/Ismail-Benali/NatsuMacTool/blob/main/LICENSE) ![Bash](https://img.shields.io/badge/Bash-4.0+-green?style=flat-square&logo=gnu-bash) ![Linux](https://img.shields.io/badge/Linux-NetworkManager-blue?style=flat-square&logo=linux)

## 📖 Overview

NatsuMacTool is an advanced Bash script designed to automatically randomize or manage MAC addresses for network interfaces using NetworkManager (nmcli).

In v2.1.0, we introduced targeted interface selection (`-i`), hardware MAC restoration (`-r`), and an automated system-wide installer (`install.sh`) to simplify deployment as a systemd service.

## ✨ Features

- 🔒 **LAA-Compliant MAC Generation:** Generates valid Locally Administered Addresses (starting with 02) to prevent OUI conflicts and network bans.
- 🎯 **Targeted Interface Selection:** Choose to randomize a specific interface (e.g., `natsumactool -i wlan0`) or all active interfaces.
- ↩️ **MAC Restoration:** Easily revert back to your original hardware MAC address using `natsumactool --restore`.
- 🛡️ **Safety Filters:** Automatically skips loopback and virtual/container interfaces (`lo`, `docker*`, `virbr*`, `tun*`, `veth*`, `br-*`) to prevent breaking system services.
- 🧪 **Dry-Run Mode:** Preview all intended changes safely before applying them (`--dry-run` or `-d`).
- 📝 **Persistent Logging:** All successful changes are logged with timestamps to `/var/log/natsumactool.log`.
- ✅ **Post-Change Verification:** Confirms the MAC address was successfully applied before reporting success.

## 🚀 Installation & Usage

### 1. One-Click System-Wide Installation

Clone the repository and run the automated installer with root privileges:

```bash
git clone https://github.com/Ismail-Benali/NatsuMacTool.git
cd NatsuMacTool
sudo ./install.sh
```

This installs `natsumactool` globally to `/usr/local/bin` and sets up the systemd auto-start service automatically.

### 2. Manual Command-Line Usage

Once installed (or run directly from the folder with `./NatsuMacTool.sh`):

- **Randomize all active interfaces:**
  ```bash
  sudo natsumactool
  ```

- **Target a specific interface:**
  ```bash
  sudo natsumactool --interface wlan0
  # or short flag:
  sudo natsumactool -i eth0
  ```

- **Restore original hardware MAC:**
  ```bash
  sudo natsumactool --restore
  ```

- **Simulate changes (Dry-Run):**
  ```bash
  sudo natsumactool --dry-run
  ```

- **Show help and options:**
  ```bash
  natsumactool --help
  ```

## 📊 Log File

All successful MAC address changes are recorded in:
```text
/var/log/natsumactool.log
```
View the history in real-time:
```bash
sudo tail -f /var/log/natsumactool.log
```

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

Made with ❤️ by [Ismail Benali](https://github.com/Ismail-Benali)
