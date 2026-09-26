![NatsuMacTool Banner](https://github.com/Ismail-Benali/NatsuMacTool/assets/90980178/a0d62156-77ad-4708-85e1-5066e1686a32)

# 🛡️ NatsuMacTool v2.2.0 (Ultimate Edition)

**An advanced, production-ready MAC address spoofer and manager for Linux with config file support, status monitoring, and NetworkManager dispatcher triggers.**

[![Release](https://img.shields.io/github/v/release/Ismail-Benali/NatsuMacTool?style=flat-square&color=blue)](https://github.com/Ismail-Benali/NatsuMacTool/releases) [![License](https://img.shields.io/github/license/Ismail-Benali/NatsuMacTool?style=flat-square&color=green)](https://github.com/Ismail-Benali/NatsuMacTool/blob/main/LICENSE) ![Bash](https://img.shields.io/badge/Bash-4.0+-green?style=flat-square&logo=gnu-bash) ![Linux](https://img.shields.io/badge/Linux-NetworkManager-blue?style=flat-square&logo=linux)

## 📖 Overview

NatsuMacTool is a powerful Bash script designed to manage and randomize MAC addresses securely. 

In v2.2.0 (Ultimate Edition), we added:
- **Status Dashboard (`--status`):** Inspect hardware vs. spoofed MAC addresses of all interfaces instantly.
- **Configuration File (`/etc/natsumactool.conf`):** Easily blacklist or exclude interfaces you don't want modified.
- **NetworkManager Dispatcher Hook:** Automatically trigger MAC randomization whenever an interface comes up.
- **Fallback mechanism:** Direct `iproute2` (`ip link`) support if NetworkManager profiles aren't active.

## ✨ Features

- 🔒 **LAA-Compliant MAC Generation:** Generates valid Locally Administered Addresses (starting with `02`).
- 📊 **Interface Status Table:** View current and permanent MAC addresses (`sudo natsumactool --status`).
- 🎯 **Targeted Interface Selection:** Target a specific interface (`sudo natsumactool -i wlan0`).
- ↩️ **MAC Restoration:** Revert back to original hardware MAC (`sudo natsumactool --restore`).
- 🛡️ **Configurable Blacklist:** Exclude sensitive interfaces via `/etc/natsumactool.conf`.
- ⚡ **Dual Engine Support:** Works seamlessly with NetworkManager profiles or direct `ip link` fallback.

## 🚀 Installation & Usage

### 1. One-Click System-Wide Installation

```bash
git clone https://github.com/Ismail-Benali/NatsuMacTool.git
cd NatsuMacTool
sudo ./install.sh
```

### 2. Check Interface Status

View a clean status table of all your network interfaces, showing their types, current spoofed MACs, and permanent hardware MACs:

```bash
sudo natsumactool --status
```

### 3. Command Reference

- **Randomize all eligible interfaces:**
  ```bash
  sudo natsumactool
  ```
- **Target a specific interface:**
  ```bash
  sudo natsumactool -i wlan0
  ```
- **Restore original hardware MAC:**
  ```bash
  sudo natsumactool --restore
  ```
- **Simulate changes (Dry-Run):**
  ```bash
  sudo natsumactool --dry-run
  ```

## ⚙️ Configuration File

Located at `/etc/natsumactool.conf`:

```bash
# NatsuMacTool Configuration File
# Add network interfaces you want to exclude from MAC randomization (space-separated)
EXCLUDE_INTERFACES=("lo")
```

## 📜 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

Made with ❤️ by [Ismail Benali](https://github.com/Ismail-Benali)
