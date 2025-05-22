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

```sh
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

- `./pcie_down.sh`: powers off dGPU completely with PCIE power control.

The results are similar as putting dGPU into `D3Cold` state, but prevents random power boosts with NVIDIA power management.

To re-enable dGPU, run any program that uses your NVIDIA card, and `pciehp` should automatically power up dGPU again.

Or you can use `pcie_up.sh` to manually power it up.

- `./pcie_up.sh`: powers on dGPU. Counterpart of `pcie_down.sh`.

- `./auto_gpu_power.sh`: automatically powers on/off dGPU based on Xorg mode.

  Add it to places like `/usr/share/sddm/scripts/Xsetup` if you want to automatically power off dGPU when in integrated mode.

- `./optimus.sh`: toggles Xorg GPU mode.

This script controls Xorg to either use iGPU only or both GPUs.

Usage: `sudo optimus.sh [integrated, hybrid]`

In integrated mode, dGPU is invisible to Xorg and there should be no process running using dGPU (except if you PRIME offloaded any application).

Therefore, the GPU should freely go into `D3Cold` state to save power. (Use `powernow.sh` to verify).

Also, any displays connected to dGPU would not work (like HDMI).

In hybrid mode, dGPU is activated and Xorg will be using it. All the monitors should work without any problems.

- `./powernow.sh`: checks current battery power consumption.

Unplug the laptop and run it. It should give something like this:

```text
D3Cold
D0
7.821 W
```

## Improve Battery Life

There are some tips to improve battery life further. It's recommended to use `tlp` to apply these tweaks.

With these tweaks, the power consumption can be lowered to around 6W when idle, 7-9W when under normal load and maximum 15W when under heavy load.

- Power off dGPU entirely with `pcie_down.sh` script.

- Or enable Runtime D3 power management:

  Follow the steps in NVIDIA Driver section.

  Option `NVreg_DynamicPowerManagement` decides the power management mode.

  - `0x02` is for fine-grained power management (recommended).

  - `0x01` is for coarse power management.

  For the difference, refer to [NVIDIA's documentation](https://download.nvidia.com/XFree86/Linux-x86_64/435.17/README/dynamicpowermanagement.html)

- Set AMD iGPU DPM performance level to `low`

  Highly recommended. This can save about 3W when idle and prevents sudden peaks in power usage when opening applications.

  With `tlp`, you can add the following lines to the config:

  ```py
  RADEON_DPM_PERF_LEVEL_ON_AC=auto
  RADEON_DPM_PERF_LEVEL_ON_BAT=low
  ```

- Disable CPU Frequency Boosting

  Recommended. This lowers the peak frequency from 4.37 GHz to 2.0 GHz and saves a lot of power.

  With `tlp`, add the following line to the config:

  ```py
  CPU_BOOST_ON_AC=1
  CPU_BOOST_ON_BAT=0
  ```

  Note: further limiting the CPU frequency actually CANNOT save any significant power. Disabling boost is enough.

- Set PCIE ASPM to `powersupersave`

  Recommended. This can save about 1W.

  With `tlp`, add the following lines to the config:

  ```py
  PCIE_ASPM_ON_AC=default
  PCIE_ASPM_ON_BAT=powersupersave
  ```

- Set platform ACPI profile to `quiet`

  This is the default behavior if you are using `asusctl`. With `tlp`, add the following lines to the config:

  ```py
  PLATFORM_PROFILE_ON_BAT=quiet
  ```

- Disable watchdog

  NMI watchdog is by default disabled by `tlp`. You can further disable `sp5100_tco` watchdog by blacklisting it.
  
  Add the following line to `/etc/modprobe.d/disable-watchdog.conf`:

  ```sh
  blacklist sp5100_tco
  ```

- Set CPU EPP to `power`

  Add the following line to the config:

  ```py
  CPU_ENERGY_PERF_POLICY_ON_BAT=power
  ```

## Known Issues

Some fixed issues are still displayed here for reference on older kernels.

- [x] Kernel Oops: divide error in CalculateVMAndRowBytes

  Fixed in 6.14 by [agd5f/linux@4408b59e](https://gitlab.freedesktop.org/agd5f/linux/-/commit/4408b59eeacfea777aae397177f49748cadde5ce), [agd5f/linux@afcdf51d](https://gitlab.freedesktop.org/agd5f/linux/-/commit/afcdf51d97cd58dd7a2e0aa8acbaea5108fa6826), [agd5f/linux@366e77cd](https://gitlab.freedesktop.org/agd5f/linux/-/commit/366e77cd4923c3aa45341e15dcaf3377af9b042f)

- [x] USBC kworker/u96:1:13 hang after plugging in USBC devices

  Fixed in 6.14. However display over USBC failed to work.

- [ ] Aquamarine (Hyprland) crash
