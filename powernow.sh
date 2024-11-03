#!/bin/bash
cat /sys/class/drm/card{0,1}/device/power_state
cat /sys/class/power_supply/BAT*/current_now /sys/class/power_supply/BAT*/voltage_now | xargs | awk '{print $1*$2/1e12 " W"}'
