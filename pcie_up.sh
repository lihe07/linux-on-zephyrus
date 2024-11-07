#!/bin/bash

echo "Powering up PCI slot..."
echo 1 | tee /sys/bus/pci/slots/0-2/power
