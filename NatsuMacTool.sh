#!/bin/bash

cat << "EOF"
  _   _       _             __  __         _______          _ 
 | \ | |     | |           |  \/  |       |__   __|        | |
 |  \| | __ _| |_ ___ _   _| \  / | __ _  ___| | ___   ___ | |
 | . ` |/ _` | __/ __| | | | |\/| |/ _` |/ __| |/ _ \ / _ \| |
 | |\  | (_| | |_\__ \ |_| | |  | | (_| | (__| | (_) | (_) | |
 |_| \_|\__,_|\__|___/\__,_|_|  |_|\__,_|\___|_|\___/ \___/|_|
                                                              
                                                              
EOF

# ==============================================================================
# NatsuMacTool - Production Ready Edition v2.0.0
# Description: A secure and reliable tool to randomly change MAC addresses 
#              for active network interfaces using NetworkManager.
# Requirements: Bash, NetworkManager (nmcli), Root privileges (sudo)
# ==============================================================================

# Output colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log file path
LOG_FILE="/var/log/natsumactool.log"

# Function to log messages to both console and file safely
log_message() {
    # Print colored message to console
    echo -e "$1"
    
    # Strip ANSI color codes and append to log file safely
    local raw_msg
    raw_msg=$(echo -e "$1" | sed -r 's/\x1b\[[0-9;]*m//g')
    echo "$raw_msg" >> "$LOG_FILE"
}

# 1. Root Privilege Check
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] Error: Please run this script with root privileges (use sudo).${NC}"
    exit 1
fi

# 2. NetworkManager Dependency Check
if ! command -v nmcli &> /dev/null; then
    echo -e "${RED}[!] Error: 'nmcli' not found. Please ensure NetworkManager is installed.${NC}"
    exit 1
fi

# 3. Argument Parsing (Dry-Run Mode)
DRY_RUN=false
if [[ "$1" == "--dry-run" || "$1" == "-d" ]]; then
    DRY_RUN=true
    log_message "${YELLOW}[*] Dry-Run mode enabled. No actual changes will be applied to the system.${NC}"
fi

# 4. Function to generate a valid, random Locally Administered Address (LAA)
# Starting with '02' ensures the MAC is recognized as random/local and prevents OUI conflicts.
generate_random_mac() {
    printf '02:%02x:%02x:%02x:%02x:%02x\n' \
        $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)) \
        $((RANDOM % 256)) $((RANDOM % 256))
}

log_message "${BLUE}===========================================================${NC}"
log_message "${BLUE}          Starting NatsuMacTool v2.0.0 (Production Ready)  ${NC}"
log_message "${BLUE}===========================================================${NC}"

# 5. Fetch active network interfaces (Ethernet and Wi-Fi only)
mapfile -t devices < <(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2 ~ /ethernet|wifi/ {print $1}')

if [ ${#devices[@]} -eq 0 ]; then
    log_message "${YELLOW}[-] No active Ethernet or Wi-Fi interfaces found.${NC}"
    exit 0
fi

# 6. Iterate over each interface and process it
for interface in "${devices[@]}"; do
    # Exclude loopback and virtual/container interfaces for safety
    if [[ "$interface" == "lo" || "$interface" == docker* || "$interface" == virbr* || "$interface" == tun* || "$interface" == tap* || "$interface" == veth* || "$interface" == br-* ]]; then
        continue
    fi

    # Get current MAC address
    current_mac=$(nmcli -t -f GENERAL.HWADDR device show "$interface" | cut -d= -f2)
    
    # Skip if MAC address is empty or unavailable
    if [[ -z "$current_mac" || "$current_mac" == "--" ]]; then
        continue
    fi

    # Find the active Connection Profile name associated with this specific device
    # This fixes the critical bug of assuming the device name equals the connection name
    conn_name=$(nmcli -t -f NAME,DEVICE connection show --active | awk -F: -v dev="$interface" '$2 == dev {print $1; exit}')

    if [[ -z "$conn_name" ]]; then
        log_message "${YELLOW}[-] Warning: No active connection profile found for interface $interface. Skipping.${NC}"
        continue
    fi

    # Generate new random MAC
    new_mac=$(generate_random_mac)

    log_message "[*] Processing interface: ${GREEN}$interface${NC} (Connection: ${BLUE}$conn_name${NC})"
    log_message "    Current MAC: $current_mac"
    log_message "    New MAC:     ${GREEN}$new_mac${NC}"

    if [ "$DRY_RUN" = true ]; then
        log_message "    ${YELLOW}[DRY-RUN] Skipped applying changes.${NC}"
    else
        # Modify the connection profile (specifying both ensures compatibility across all NM versions)
        if nmcli connection modify "$conn_name" ethernet.cloned-mac-address "$new_mac" wifi.cloned-mac-address "$new_mac" 2>/dev/null; then
            
            # Restart the connection to apply changes immediately
            nmcli connection down "$conn_name" >/dev/null 2>&1
            sleep 2 # Increased for stability on slower hardware
            nmcli connection up "$conn_name" >/dev/null 2>&1
            sleep 2 # Allow time for the interface to fully re-initialize and get DHCP

            # Verify that the change was successfully applied
            verify_mac=$(nmcli -t -f GENERAL.HWADDR device show "$interface" | cut -d= -f2)
            
            if [[ "$verify_mac" == "$new_mac" ]]; then
                log_message "    ${GREEN}[+] Successfully applied and verified.${NC}"
                echo "$(date '+%Y-%m-%d %H:%M:%S') | SUCCESS | Interface: $interface | Conn: $conn_name | Old: $current_mac | New: $new_mac" >> "$LOG_FILE"
            else
                log_message "    ${RED}[!] Warning: Settings modified, but verification failed. Actual MAC is: $verify_mac${NC}"
            fi
        else
            log_message "    ${RED}[!] Failed to modify connection profile: $conn_name${NC}"
        fi
    fi
    log_message "-----------------------------------------------------------"
done

log_message "${GREEN}[✓] Operation completed successfully.${NC}"
