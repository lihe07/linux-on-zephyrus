#!/bin/bash

PCI="0000:64:00.0"

echo "Unloading NVIDIA drivers..."

modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia_wmi_ec_backlight nvidia

echo "Removing PCI device..."
echo 1 | tee /sys/bus/pci/devices/$PCI/remove
