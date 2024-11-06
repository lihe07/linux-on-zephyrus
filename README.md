# Linux on ROG Zephyrus G16 Air (2024)

Some scripts for better experience with your Zephyrus G16 Air.

My model is G16 Air Ryzen AI 9 version.

## Environment

- OS: Any Arch based distro (I've tested archlinux & artixlinux). Other distros may also work.

- WM & DE: Xfce4 (Wayland compositors do not work quite well. The internal display gives `InvalidMode`)

- Display Manager: SDDM, LightDM

- Packages: `asusctl` for LEDs and profiles. `nvidia-prime` for `prime-run` util.

  `supergfxctl` and `optimus-manager` are not needed.

- Driver: `nvidia` (proprietary). No need to install any xorg-drivers like `xf86-video-amdgpu`. `modesetting` driver is used for iGPU.

## Configuration

- NVIDIA Driver:

Create `/etc/modprobe.d/nvidia.conf` file, write following config:

```
blacklist nouveau

options nvidia NVreg_DynamicPowerManagement=0x02
options nvidia-drm modeset=1 fbdev=1
```

This disables `nouveau` driver, enables Dynamic D3 Power Management, ModeSet and fbdev (for tty consoles).

If you need tty consoles to show up on internal display + iGPU connected monitors, add `fbcon=map:0` to kernel flags.

- SDDM:

If you see a black screen / SDDM only shows up on some displays, add `xrandr --auto` to `/usr/share/sddm/scripts/Xsetup`.

This automatically scans for connected monitors and enables them.

- Xorg:

Random screen freezing while in integrated mode can be resolved by disabling PageFlip.

This is already the default config in my scripts.

## Scripts

- `./pcie_down.sh`: powers off dGPU entirely with PCIE power control. 

The results are similar as putting dGPU into `D3Cold` state, but prevents random power boosts with NVIDIA power management.

To re-enable dGPU, run any program that uses your NVIDIA card, and `pciehp` should automatically power up dGPU again.

Or simply run `cat /sys/bus/pci/slots/0-2/power`

- `./optimus.sh`: toggles Xorg GPU usage

This script controls Xorg to either use iGPU only or both GPUs.

Usage: `sudo optimus.sh [integrated, hybrid]`

In integrated mode, dGPU is invisible to Xorg and there should be no process running using dGPU (except if you PRIME offloaded any application).

Therefore, the GPU should freely go into `D3Cold` state to save power. (Use `powernow.sh` to verify).

Also, any displays connected to dGPU would not work (like HDMI).

In hybrid mode, dGPU is activated and Xorg will be using it. All the monitors should work without any problems.

- `./powernow.sh`: checks current power consumption

Unplug the laptop and run it. It should give something like this:

```
D3Cold
D0
7.821 W
```
