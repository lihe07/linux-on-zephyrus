#/bin/bash

CONFIG_FILE="/usr/share/X11/xorg.conf.d/20-optimus.conf"
current_mode=$(head -n 1 "$CONFIG_FILE")

if [[ "$current_mode" == "# Hybrid mode" ]]; then
  echo "Xorg config is Hybrid mode. Powering Up dGPU."
  /bin/pcie_up.sh
elif [[ "$current_mode" == "# Integrated mode" ]]; then
  echo "Xorg config is Integrated mode. Powering Down dGPU."
  /bin/pcie_down.sh
else
  echo "Unknown mode in Xorg config."
fi
