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
# NatsuMacTool - Production Ready Edition v2.1.0
# Description: A secure and reliable tool to randomly or permanently manage 
#              MAC addresses for active network interfaces using NetworkManager.
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

LOG_FILE="/var/log/natsumactool.log"

log_message() {
    echo -e "$1"
    local raw_msg
    raw_msg=$(echo -e "$1" | sed -r 's/\x1b\[[0-9;]*m//g')
    echo "$raw_msg" >> "$LOG_FILE" 2>/dev/null || true
}

show_help() {
    echo -e "Usage: sudo natsumactool [OPTIONS]"
    echo -e "Options:"
    echo -e "  -i, --interface <dev>  Target a specific interface (e.g., wlan0, eth0)"
    echo -e "  -r, --restore          Restore original/default hardware MAC address"
    echo -e "  -d, --dry-run          Simulate actions without applying changes"
    echo -e "  -h, --help             Show this help message"
}

# 1. Root Check
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] Error: Please run with root privileges (sudo).${NC}"
    exit 1
fi

# 2. Dependency Check
if ! command -v nmcli &> /dev/null; then
    echo -e "${RED}[!] Error: 'nmcli' not found. NetworkManager is required.${NC}"
    exit 1
fi

# 3. Argument Parsing
DRY_RUN=false
RESTORE_MODE=false
TARGET_INTERFACE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -d|--dry-run) DRY_RUN=true ;;
        -r|--restore) RESTORE_MODE=true ;;
        -i|--interface) TARGET_INTERFACE="$2"; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) echo -e "${RED}[!] Unknown parameter: $1${NC}"; show_help; exit 1 ;;
    esac
    shift
done

generate_random_mac() {
    printf '02:%02x:%02x:%02x:%02x:%02x\n' \
        $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)) \
        $((RANDOM % 256)) $((RANDOM % 256))
}

log_message "${BLUE}===========================================================${NC}"
log_message "${BLUE}          NatsuMacTool v2.1.0 (Execution Started)          ${NC}"
log_message "${BLUE}===========================================================${NC}"

# 4. Fetch Devices
if [ -n "$TARGET_INTERFACE" ]; then
    devices=("$TARGET_INTERFACE")
else
    mapfile -t devices < <(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2 ~ /ethernet|wifi/ {print $1}')
fi

if [ ${#devices[@]} -eq 0 ]; then
    log_message "${YELLOW}[-] No matching Ethernet or Wi-Fi interfaces found.${NC}"
    exit 0
fi

# 5. Process Interfaces
for interface in "${devices[@]}"; do
    if [[ "$interface" == "lo" || "$interface" == docker* || "$interface" == virbr* || "$interface" == tun* || "$interface" == tap* || "$interface" == veth* || "$interface" == br-* ]]; then
        continue
    fi

    current_mac=$(nmcli -t -f GENERAL.HWADDR device show "$interface" 2>/dev/null | sed 's/^GENERAL.HWADDR://')
    if [[ -z "$current_mac" || "$current_mac" == "--" ]]; then
        log_message "${YELLOW}[-] Interface $interface is down or unavailable. Skipping.${NC}"
        continue
    fi

    conn_name=$(nmcli -t -f NAME,DEVICE connection show --active | awk -F: -v dev="$interface" '$2 == dev {print $1; exit}')
    if [[ -z "$conn_name" ]]; then
        log_message "${YELLOW}[-] No active connection profile found for $interface. Skipping.${NC}"
        continue
    fi

    conn_type=$(nmcli -t -f TYPE connection show "$conn_name" | cut -d: -f2)
    modify_cmd=$([[ "$conn_type" == "802-11-wireless" ]] && echo "wifi.cloned-mac-address" || echo "ethernet.cloned-mac-address")

    if [ "$RESTORE_MODE" = true ]; then
        log_message "[*] Restoring original MAC for: ${GREEN}$interface${NC} (Connection: ${BLUE}$conn_name${NC})"
        if [ "$DRY_RUN" = true ]; then
            log_message "    ${YELLOW}[DRY-RUN] Skipped restore.${NC}"
        else
            nmcli connection modify "$conn_name" "$modify_cmd" "default" >/dev/null 2>&1
            nmcli connection down "$conn_name" >/dev/null 2>&1 && sleep 2
            nmcli connection up "$conn_name" >/dev/null 2>&1 && sleep 2
            log_message "    ${GREEN}[+] Restored to hardware default.${NC}"
        fi
    else
        new_mac=$(generate_random_mac)
        log_message "[*] Processing interface: ${GREEN}$interface${NC} (Connection: ${BLUE}$conn_name${NC})"
        log_message "    Current MAC: $current_mac"
        log_message "    New MAC:     ${GREEN}$new_mac${NC}"

        if [ "$DRY_RUN" = true ]; then
            log_message "    ${YELLOW}[DRY-RUN] Skipped applying changes.${NC}"
        else
            if nmcli connection modify "$conn_name" "$modify_cmd" "$new_mac" 2>/dev/null; then
                nmcli connection down "$conn_name" >/dev/null 2>&1 && sleep 2
                nmcli connection up "$conn_name" >/dev/null 2>&1 && sleep 2

                verify_mac=$(nmcli -t -f GENERAL.HWADDR device show "$interface" | sed 's/^GENERAL.HWADDR://')
                if [[ "$verify_mac" == "$new_mac" ]]; then
                    log_message "    ${GREEN}[+] Successfully applied and verified.${NC}"
                else
                    log_message "    ${RED}[!] Warning: Settings applied, but verification failed. Current: $verify_mac${NC}"
                fi
            else
                log_message "    ${RED}[!] Failed to modify profile: $conn_name${NC}"
            fi
        fi
    fi
    log_message "-----------------------------------------------------------"
done

log_message "${GREEN}[✓] Operation completed successfully.${NC}"
