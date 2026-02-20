# Linux on ROG Zephyrus G16 Air (2024)

Some scripts for better experience with your Zephyrus G16 Air.

My model is G16 Air Ryzen AI 9 version.

## Environment

- OS: Any Arch based distro (I've tested archlinux & artixlinux). Other distros may also work.

- WM & DE: 

  [COSMIC](https://system76.com/cosmic) works out of the box with no issues. Also has great support for hybrid mode and GPU switching.

  Most Xorg based WMs and DEs should work fine (i3, bspwm, dwm, xfce, kde, gnome etc).

  Sway works if you set `WLR_DRM_DEVICES` to iGPU only.

  Hyprland currently crashes.

- Display Manager: SDDM, LightDM

- Packages: `asusctl` for LEDs and profiles. `nvidia-prime` for `prime-run` util.

  `supergfxctl` for GPU switching

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

- Sway:

Always set `WLR_DRM_DEVICES` to iGPU only, except in Mux dGPU mode.

## Scripts

PCIE scripts are deprecated in favor of [SuperGFXCTL](https://gitlab.com/asus-linux/supergfxctl).

Brightness control can be done via brightnessctl


## Improve Battery Life

There are some tips to improve battery life further. It's recommended to use `tlp` to apply these tweaks.

With these tweaks, the power consumption can be lowered to around 6W when idle, 7-9W when under normal load and maximum 15W when under heavy load.

- Power off dGPU entirely with supergfxctl.

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

- [x] Internal Microphone not working

  Fixed in 6.15

- [ ] Sway crash in Hybrid mode

  The internal panel is wired to iGPU only. In hybrid mode, Sway tries to use dGPU for rendering which causes a crash.

- [ ] Aquamarine (Hyprland) crash

  Following at this [discussion](https://github.com/hyprwm/Hyprland/discussions/10248).

- [ ] Brightness control not working in Mux dGPU mode

  Unresolved.
