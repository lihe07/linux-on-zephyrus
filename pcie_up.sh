#!/bin/bash

echo "Powering up PCI slot..."
echo 1 | tee /sys/bus/pci/rescan
