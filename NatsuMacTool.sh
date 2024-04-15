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

# Get a list of all network interfaces and their corresponding MAC addresses
interfaces_and_macs=$(nmcli -t -f NAME,GENERAL.HWADDR device show)

# Iterate over each network interface and set a unique random MAC address
while IFS= read -r line; do
    # Extract interface name and current MAC address from the line
    interface=$(echo "$line" | cut -d: -f1)
    current_mac=$(echo "$line" | cut -d: -f2)
    
    # Generate a random MAC address
    random_mac=$(generate_random_mac)
    
    # Set the random MAC address for the network interface
    nmcli connection modify "$interface" ethernet.cloned-mac-address "$random_mac"
    
    # Output the interface name, its current MAC address, and the new MAC address
    echo "Interface: $interface - Current MAC Address: $current_mac - New MAC Address: $random_mac"
done <<< "$interfaces_and_macs"
