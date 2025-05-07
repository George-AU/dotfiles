#!/bin/bash

# First install jq: sudo pacman -S jq

# Check if there's any active connection
if nmcli -t -f STATE general status | grep -q "connected"; then
    # Get the active interface more reliably
    interface=$(ip -o route get 1 | awk '{print $5; exit}')
    ipaddr=$(ip -4 -o addr show $interface | awk '{print $4}' | cut -d'/' -f1)
    ssid=""

    if [[ $interface == wl* ]]; then
        ssid=$(nmcli -t -f NAME connection show --active | head -n1)
    fi

    if [[ -n "$ssid" ]]; then
        echo "$ssid: $ipaddr"
    else
        echo "$ipaddr"
    fi
else
    echo "disconnected"
fi
