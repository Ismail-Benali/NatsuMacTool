#!/bin/bash
# NetworkManager Dispatcher Script for NatsuMacTool
# Automatically triggers MAC randomization when an interface comes up.

INTERFACE=$1
ACTION=$2

# Only trigger on 'up' action for wireless or ethernet interfaces
if [[ "$ACTION" == "up" && ("$INTERFACE" =~ ^wl || "$INTERFACE" =~ ^en || "$INTERFACE" =~ ^eth) ]]; then
    # Run natsumactool specifically for this interface in the background
    /usr/local/bin/natsumactool --interface "$INTERFACE" >> /var/log/natsumactool.log 2>&1 &
fi
