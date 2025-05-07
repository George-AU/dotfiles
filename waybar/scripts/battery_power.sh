#!/bin/bash

if [ -f "/sys/class/power_supply/BAT0/power_now" ]; then
    status=$(cat /sys/class/power_supply/BAT0/status)
    power=$(awk '{printf "%.2f", $1/1000000}' /sys/class/power_supply/BAT0/power_now)
    
    # Make power negative when discharging
    if [ "$status" = "Discharging" ]; then
        power=$(awk -v p="$power" 'BEGIN{printf "%.2f", -p}')
    fi
    
    echo "$power"
else
    echo "N/A"
fi
