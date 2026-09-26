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
# NatsuMacTool - Ultimate Edition v2.2.0
# Description: Advanced MAC address spoofer & manager for Linux with 
#              config file support, status monitoring, and dispatcher triggers.
# ==============================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

LOG_FILE="/var/log/natsumactool.log"
CONFIG_FILE="/etc/natsumactool.conf"

# Default configuration
EXCLUDE_INTERFACES=("lo")

# Load configuration file if it exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

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
    echo -e "  -s, --status           Show current MAC status of all network interfaces"
    echo -e "  -r, --restore          Restore original/default hardware MAC address"
    echo -e "  -d, --dry-run          Simulate actions without applying changes"
    echo -e "  -h, --help             Show this help message"
}

# 1. Status Command Function
show_status() {
    echo -e "${BLUE}===========================================================${NC}"
    echo -e "${BLUE}           NatsuMacTool - Network Interfaces Status        ${NC}"
    echo -e "${BLUE}===========================================================${NC}"
    printf "%-12s | %-12s | %-18s | %-18s\n" "INTERFACE" "TYPE" "CURRENT MAC" "HARDWARE MAC"
    echo "-----------------------------------------------------------"

    while read -r line; do
        if [ -z "$line" ]; then continue; fi
        local dev=$(echo "$line" | awk '{print $1}')
        local type=$(echo "$line" | awk '{print $2}')
        
        # Skip loopback and virtual
        if [[ "$dev" == "lo" || "$dev" =~ ^(docker|virbr|tun|tap|veth|br-) ]]; then
            continue
        fi

        local curr_mac=$(ip -o link show "$dev" 2>/dev/null | awk '{print $9}')
        local perm_mac=$(ethtool -P "$dev" 2>/dev/null | awk '{print $3}')
        if [ -z "$perm_mac" ]; then
            perm_mac="N/A (Virtual/Not supported)"
        fi

        printf "%-12s | %-12s | ${GREEN}%-18s${NC} | ${CYAN}%-18s${NC}\n" "$dev" "$type" "$curr_mac" "$perm_mac"
    done < <(nmcli -t -f DEVICE,TYPE device status 2>/dev/null || ip -o link show | awk -F': ' '{print $2 " unknown"}')
    echo -e "${BLUE}===========================================================${NC}"
}

# 2. Root Check
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] Error: Please run with root privileges (sudo).${NC}"
    exit 1
fi

# 3. Argument Parsing
DRY_RUN=false
RESTORE_MODE=false
STATUS_MODE=false
TARGET_INTERFACE=""

while [[ "$#" -gt 0 ]]; do
    case $1 in
        -d|--dry-run) DRY_RUN=true ;;
        -r|--restore) RESTORE_MODE=true ;;
        -s|--status) STATUS_MODE=true ;;
        -i|--interface) TARGET_INTERFACE="$2"; shift ;;
        -h|--help) show_help; exit 0 ;;
        *) echo -e "${RED}[!] Unknown parameter: $1${NC}"; show_help; exit 1 ;;
    esac
    shift
done

if [ "$STATUS_MODE" = true ]; then
    show_status
    exit 0
fi

# Dependency Check
if ! command -v nmcli &> /dev/null && ! command -v ip &> /dev/null; then
    echo -e "${RED}[!] Error: Neither 'nmcli' nor 'ip' command found.${NC}"
    exit 1
fi

generate_random_mac() {
    printf '02:%02x:%02x:%02x:%02x:%02x\n' \
        $((RANDOM % 256)) $((RANDOM % 256)) $((RANDOM % 256)) \
        $((RANDOM % 256)) $((RANDOM % 256))
}

log_message "${BLUE}===========================================================${NC}"
log_message "${BLUE}          NatsuMacTool v2.2.0 (Execution Started)          ${NC}"
log_message "${BLUE}===========================================================${NC}"

# 4. Fetch Devices
if [ -n "$TARGET_INTERFACE" ]; then
    devices=("$TARGET_INTERFACE")
else
    mapfile -t devices < <(nmcli -t -f DEVICE,TYPE device status 2>/dev/null | awk -F: '$2 ~ /ethernet|wifi/ {print $1}')
    if [ ${#devices[@]} -eq 0 ]; then
        mapfile -t devices < <(ip -o link show | awk -F': ' '{print $2}' | grep -E '^(wl|en|eth)')
    fi
fi

if [ ${#devices[@]} -eq 0 ]; then
    log_message "${YELLOW}[-] No matching Ethernet or Wi-Fi interfaces found.${NC}"
    exit 0
fi

# 5. Process Interfaces
for interface in "${devices[@]}"; do
    # Check exclusion list from config
    skip=false
    for excluded in "${EXCLUDE_INTERFACES[@]}"; do
        if [[ "$interface" == "$excluded" ]]; then
            skip=true
            break
        fi
    done

    if [ "$skip" = true ]; then
        log_message "[*] Interface $interface is excluded in config. Skipping."
        continue
    fi

    if [[ "$interface" == "lo" || "$interface" == docker* || "$interface" == virbr* || "$interface" == tun* || "$interface" == tap* || "$interface" == veth* || "$interface" == br-* ]]; then
        continue
    fi

    current_mac=$(ip -o link show "$interface" 2>/dev/null | awk '{print $9}')
    if [[ -z "$current_mac" ]]; then
        log_message "${YELLOW}[-] Interface $interface is unavailable. Skipping.${NC}"
        continue
    fi

    # Try NetworkManager first
    conn_name=$(nmcli -t -f NAME,DEVICE connection show --active 2>/dev/null | awk -F: -v dev="$interface" '$2 == dev {print $1; exit}')

    if [ "$RESTORE_MODE" = true ]; then
        log_message "[*] Restoring original MAC for: ${GREEN}$interface${NC}"
        if [ "$DRY_RUN" = true ]; then
            log_message "    ${YELLOW}[DRY-RUN] Skipped restore.${NC}"
        else
            if [ -n "$conn_name" ]; then
                conn_type=$(nmcli -t -f TYPE connection show "$conn_name" 2>/dev/null | cut -d: -f2)
                modify_cmd=$([[ "$conn_type" == "802-11-wireless" ]] && echo "wifi.cloned-mac-address" || echo "ethernet.cloned-mac-address")
                nmcli connection modify "$conn_name" "$modify_cmd" "default" >/dev/null 2>&1
                nmcli connection down "$conn_name" >/dev/null 2>&1 && sleep 2
                nmcli connection up "$conn_name" >/dev/null 2>&1 && sleep 2
            else
                # Fallback to ip link
                ip link set dev "$interface" down
                ip link set dev "$interface" address "$(ethtool -P "$interface" 2>/dev/null | awk '{print $3}')"
                ip link set dev "$interface" up
            fi
            log_message "    ${GREEN}[+] Restored to default.${NC}"
        fi
    else
        new_mac=$(generate_random_mac)
        log_message "[*] Processing interface: ${GREEN}$interface${NC}"
        log_message "    Current MAC: $current_mac"
        log_message "    New MAC:     ${GREEN}$new_mac${NC}"

        if [ "$DRY_RUN" = true ]; then
            log_message "    ${YELLOW}[DRY-RUN] Skipped applying changes.${NC}"
        else
            if [ -n "$conn_name" ]; then
                conn_type=$(nmcli -t -f TYPE connection show "$conn_name" 2>/dev/null | cut -d: -f2)
                modify_cmd=$([[ "$conn_type" == "802-11-wireless" ]] && echo "wifi.cloned-mac-address" || echo "ethernet.cloned-mac-address")
                
                if nmcli connection modify "$conn_name" "$modify_cmd" "$new_mac" 2>/dev/null; then
                    nmcli connection down "$conn_name" >/dev/null 2>&1 && sleep 2
                    nmcli connection up "$conn_name" >/dev/null 2>&1 && sleep 2
                fi
            else
                # Fallback direct ip link
                ip link set dev "$interface" down
                ip link set dev "$interface" address "$new_mac"
                ip link set dev "$interface" up
            fi

            verify_mac=$(ip -o link show "$interface" 2>/dev/null | awk '{print $9}')
            if [[ "$verify_mac" == "$new_mac" ]]; then
                log_message "    ${GREEN}[+] Successfully applied and verified.${NC}"
            else
                log_message "    ${RED}[!] Warning: Verification failed. Current: $verify_mac${NC}"
            fi
        fi
    fi
    log_message "-----------------------------------------------------------"
done

log_message "${GREEN}[✓] Operation completed successfully.${NC}"
