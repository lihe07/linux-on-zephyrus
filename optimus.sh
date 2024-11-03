#!/bin/bash

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Use sudo to run it."
   exit 1
fi

# Path to the Xorg configuration file
CONFIG_FILE="/usr/share/X11/xorg.conf.d/20-optimus.conf"

# Integrated and Hybrid configurations
INTEGRATED_CONFIG=$(cat <<EOF
# Integrated mode

Section "ServerFlags"
    Option "AutoAddGPU" "false"
    Option "DefaultServerLayout" "iGPU Layout"
EndSection

Section "Device"
    Identifier  "iGPU"
    Driver      "modesetting"
    BusID       "PCI:101:0:0"
EndSection

Section "Screen"
    Identifier "iGPU"
    Device "iGPU"
EndSection

Section "ServerLayout"
    Identifier "iGPU Layout"
    Screen "iGPU"
    Option "SingleCard" "true"
EndSection
EOF
)

HYBRID_CONFIG=$(cat <<EOF
# Hybrid mode

Section "Device"
    Identifier  "dGPU"
    Driver      "nvidia"
    BusID       "PCI:100:0:0"
    Option      "AllowEmptyInitialConfiguration" "true"
EndSection

Section "Device"
    Identifier  "iGPU"
    Driver      "modesetting"
    BusID       "PCI:101:0:0"
EndSection

Section "Screen"
    Identifier "dGPU"
    Device "dGPU"
EndSection

Section "Screen"
    Identifier "iGPU"
    Device "iGPU"
EndSection
EOF
)

# Check the current mode in the config file
current_mode=$(head -n 1 "$CONFIG_FILE")

# Function to check if the config is already in the desired mode
check_mode() {
    if [[ "$current_mode" == "# $1 mode" ]]; then
        echo "Xorg config is already in $1 mode."
        exit 0
    fi
}

# Function to change the config to the specified mode
change_config() {
    if [[ "$1" == "Integrated" ]]; then
        echo "$INTEGRATED_CONFIG" > "$CONFIG_FILE"
    elif [[ "$1" == "Hybrid" ]]; then
        echo "$HYBRID_CONFIG" > "$CONFIG_FILE"
    fi
    echo "Xorg config changed to $1 mode."
}

# If no arguments are supplied, show the current mode
if [[ -z $1 ]]; then
    if [[ "$current_mode" == "# Hybrid mode" ]]; then
        echo "Xorg config is Hybrid mode."
    elif [[ "$current_mode" == "# Integrated mode" ]]; then
        echo "Xorg config is Integrated mode."
    else
        echo "Unknown mode in Xorg config."
    fi
    exit 0
fi

# If arguments are supplied, determine the desired mode
case "$1" in
    i|integrated|Integrated)
        check_mode "Integrated"
        change_config "Integrated"
        ;;
    h|hybrid|Hybrid)
        check_mode "Hybrid"
        change_config "Hybrid"
        ;;
    *)
        echo "Invalid argument. Use 'i', 'integrated', or 'Integrated' for Integrated mode, and 'h', 'hybrid', or 'Hybrid' for Hybrid mode."
        exit 1
        ;;
esac

# Ask user if they want to log out to apply changes
read -p "Configuration changed. Do you want to log out to apply settings? (y/n): " response
if [[ "$response" == "y" ]]; then
    systemctl restart sddm
fi

