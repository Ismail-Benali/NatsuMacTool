#!/bin/bash

cat << "EOF"
  _   _       _             __  __         _______          _ 
 | \ | |     | |           |  \/  |       |__   __|        | |
 |  \| | __ _| |_ ___ _   _| \  / | __ _  ___| | ___   ___ | |
 | . ` |/ _` | __/ __| | | | |\/| |/ _` |/ __| |/ _ \ / _ \| |
 | |\  | (_| | |_\__ \ |_| | |  | | (_| | (__| | (_) | (_) | |
 |_| \_|\__,_|\__|___/\__,_|_|  |_|\__,_|\___|_|\___/ \___/|_|
                                                              
                                                              
EOF

# Function to generate a random MAC address
generate_random_mac() {
    printf '%02x:%02x:%02x:%02x:%02x:%02x\n' \
           $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)) \
           $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256))
}

# Get the network interface name
interface=$(nmcli -t -f NAME device show | head -n 1)

# Set a random MAC address for the network interface
nmcli connection modify "$interface" ethernet.cloned-mac-address "$(generate_random_mac)"