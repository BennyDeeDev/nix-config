# NixOS Android TV on Raspberry Pi 5

This host is a Pi 5-only experiment. It boots NixOS into a Cage Wayland kiosk,
starts Waydroid with a pinned Android TV image, and installs four pinned ARM64
applications without Google Play:

- NuvioTV
- SmartTube stable
- RetroArch
- Stremio

Playback testing has not been performed yet. HDMI output and CEC navigation
have been validated on the target hardware.

## Hardware

The initial target is:

- Raspberry Pi 5 with 8 GB RAM
- Active cooling
- Proper 5 V / 5 A USB-C power supply
- HDMI-connected television
- Ethernet
- A USB HID keyboard or remote for initial input testing
- A 16 GB or larger SD card for the first installation

NVMe root storage can be added after the SD-card vertical path is working.

## Image and kernel

The host uses the upstream `nixos-hardware` Raspberry Pi 5 module while
selecting the latest cached NixOS kernel. The kernel is intentional: it
provides the 4 KiB pages, Binder, BinderFS, DMA-BUF support, and Pi 5 V3D device
tree required by the selected Waydroid image without compiling a custom kernel.

The Android image is the official WayDroid-ATV release `20260106`:

- LineageOS 20 / Android TV 13
- ARM64
- VANILLA, without GApps
- System archive SHA-256:
  `e7476400749ffc326be527535bf5f158a9cfc8c1ee5e447788e76329783a6235`
- Vendor archive SHA-256:
  `0202741cab7e2bdeb3d08c86ba56c199559ab314eb21dd652b8b5a3a1c7fbb00`

The archives are fetched by Nix and extracted into immutable store paths. The
machine exposes those paths through `/etc/waydroid-extra/images`. Waydroid is
initialized when `/var/lib/waydroid/waydroid.cfg` is absent; existing Android
state is left untouched.

The graphical image is built with the Raspberry Pi firmware, DTBs, overlays,
U-Boot, and generated `config.txt` already on its static firmware partition.
The deployed host does not rewrite that FAT partition during normal NixOS
switches.

## Build an image

The bootstrap image uses cached NixOS packages and does not include Android,
APKs, or a custom kernel.

From the repository root:

```bash
nix build .#pi5-bootstrap-rpi
zstd -d result/sd-image/*.img.zst -o pi5-bootstrap-rpi.img
lsblk
sudo dd if=pi5-bootstrap-rpi.img of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

Replace `/dev/sdX` only after verifying the SD-card device with `lsblk`.

The RPi bootstrap image adds the shared Pi 5 graphical profile and statically
populates the firmware partition with the Pi firmware, DTBs, overlays, U-Boot,
and generated `config.txt`. It does not include the Android TV stack. Use it
for a fresh `pi5-tv` installation, then deploy the TV host configuration over
SSH:

```bash
nix build .#pi5-bootstrap-rpi
zstd -d result/sd-image/*.img.zst -o pi5-bootstrap-rpi.img
lsblk
sudo dd if=pi5-bootstrap-rpi.img of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

The shared Pi 5 profile provides the existing `benjamin` key-only
administration user.

## First boot

Connect Ethernet and HDMI, insert the SD card, and power on the Pi. The
graphical bootstrap starts NixOS with SSH access. After deploying `pi5-tv`, the
expected sequence is:

```text
NixOS -> Waydroid container -> Cage -> Android TV launcher
```

The Linux login prompt is not used. Cage starts directly on `tty1` as the
unprivileged `tv` user. `benjamin` is the shared-profile administration user.

The first boot can take longer than later boots because Waydroid initializes
its rootfs, starts a user session, and installs the APKs. APK provisioning runs
as the `tv` user's `android-tv-apps.service`.

## Remote deployment

Run this from the build machine after the Pi is reachable over SSH:

```bash
nixos-rebuild switch \
  --flake .#pi5-tv \
  --target-host benjamin@192.168.178.163 \
  --sudo \
  --ask-elevate-password
```

For later updates, run the same command from the repository checkout. NixOS
generations remain available for rollback:

```bash
ssh benjamin@tv
sudo nixos-rebuild switch --rollback
```

The host does not enable root SSH login and does not enable password SSH login.

## APK provisioning

The pinned application definitions live in `android-apks/` and include the
package name, version, version code, official source URL, and Nix hash.

The APK files are included in the NixOS closure and exposed through the
`android-tv/install-apps` script. The `tv` user's `android-tv-apps.service`
waits for the Waydroid session and uses the official `waydroid app install`
command for APKs without a matching persistent version marker. It:

- waits for the Waydroid session and package service;
- records the declared version code after a successful install;
- verifies package presence after installation;
- does not remove or inspect any other Android packages;
- leaves Android application data under Waydroid's persistent user state.

Adding an APK or changing its version code causes the service to install and
verify it on the next user session. Removing an APK from the declaration does
not uninstall it from Android.

### Add an APK

Create a definition in `android-apks/` using the same fields as the existing
definitions, then add it to `android-apks/default.nix`. Use the official direct
APK URL rather than a mutable download URL.

Fetch the Nix hash and store path:

```bash
url='https://example.invalid/app.apk'
nix store prefetch-file --json --hash-type sha256 "$url"
```

Copy the returned `hash` into `pkgs.fetchurl` and use the returned `storePath`
to inspect the APK metadata:

```bash
nix shell nixpkgs#aapt --command \
  aapt2 dump badging /nix/store/<prefetched-apk> \
  | grep -E '^(package:|native-code:)'
```

Use the reported package name, version name, version code, and native ABI in
the definition. For this ARM64 host, select an `arm64-v8a` APK when available.
Build and deploy the host after adding the definition; the existing installer
service discovers it automatically.

The current pinned artifacts are:

| Application | Version        | Package                 | Asset                                           |
| ----------- | -------------- | ----------------------- | ----------------------------------------------- |
| NuvioTV     | `0.8.11-beta`  | `com.nuvio.tv`          | `app-full-arm64-v8a-release.apk`                |
| SmartTube   | `32.10` stable | `org.smarttube.stable`  | `SmartTube_stable_32.10_arm64-v8a.apk`          |
| RetroArch   | `1.22.2`       | `com.retroarch.aarch64` | `RetroArch_aarch64.apk`                         |
| Stremio     | `1.10.4`       | `com.stremio.one`       | `com.stremio.one-1.10.4-33145732-arm64-v8a.apk` |

To bump an application, update its version, version code, URL, and hash in its
definition file. Verify the APK metadata with `aapt dump badging` before
deploying it. A rebuild does not remove old Android packages or reset their
data.

## Runtime Hardware State

The CEC input mount and permissions, the CEC navigation-key remapping, and the
HDMI-CEC active-source announcement are declared in `android-tv/cec.nix`. The
confirm and Back remappings are needed because the Linux VC4 driver emits
`KEY_OK` and `KEY_EXIT`, while the Android image maps `KEY_ENTER` and `KEY_BACK`
to the corresponding Android navigation actions.

One setting is intentionally manual:

- Android display density is tuned in Android rather than Nix. The privileged
  shell command is `waydroid shell wm density 320`.

The previous CMA experiments were removed. The host uses the device-tree
default CMA reservation. The `modetest` HDMI checks were diagnostic only and
did not change the host configuration. The graphical image forces the known-
good 1920x1080@60 mode; 4K remains intentionally unvalidated.

## Diagnostics

Check the host services:

```bash
sudo systemctl status waydroid-container.service
sudo systemctl status cage-tty1.service
sudo -u tv systemctl --user status android-tv-apps.service
```

Read logs:

```bash
sudo journalctl -b -u waydroid-container.service
sudo journalctl -b -u cage-tty1.service
sudo journalctl --user -u android-tv-apps.service
sudo waydroid log
sudo waydroid logcat
```

Inspect the kernel and Android devices:

```bash
getconf PAGESIZE
cat /proc/config.gz 2>/dev/null | grep -E 'CONFIG_(ANDROID_BINDER|DMABUF_HEAPS)'
ls -la /dev/dma_heap /dev/dri
sudo v4l2-ctl --list-devices
sudo evtest
```

Check the native HDMI audio boundary before debugging Android audio:

```bash
aplay -l
speaker-test -c 2 -t wav
sudo -u tv env XDG_RUNTIME_DIR=/run/user/1001 wpctl status
```

If native audio works but Waydroid remains silent, inspect the Android Pulse
bridge:

```bash
sudo waydroid shell getprop waydroid.pulse_runtime_path
sudo waydroid shell dumpsys media.audio_flinger
sudo waydroid logcat | grep -iE 'audio|pulse|alsa|AudioFlinger'
```

## Android state and image changes

Normal NixOS rebuilds do not wipe `/var/lib/waydroid` or
`/var/lib/android-tv`. Android application settings and data should therefore
survive reboots and host generations.

Changing the system or vendor image requires an explicit reset or migration.
The current host does not replace existing state automatically:

```bash
sudo systemctl stop cage-tty1.service waydroid-container.service
sudo rm -rf /var/lib/waydroid /var/lib/android-tv/.local/share/waydroid
sudo reboot
```

This deletes Android application data. Back up anything important before
running it.

## Playback test plan

These tests are intentionally not claimed as complete until performed on the
Pi:

- SmartTube at 1080p, 1080p60, and 4K where available
- seeking, audio, and fullscreen playback
- NuvioTV navigation, metadata, player launch, seeking and return to UI
- RetroArch launch, D-pad navigation and controller enumeration
- CPU utilization, memory, temperature, dropped frames, Waydroid logs and
  kernel/video errors during playback

The Pi 5 can output 4K and has an HEVC decoder, but this Waydroid ARM64 image
does not automatically provide a Raspberry Pi V4L2 Codec2 path. 4K YouTube
streams may therefore use software VP9 or AV1 decoding. The final result must
record the actual codec, CPU usage and dropped-frame behavior rather than
assuming that 4K output implies 4K playback capability.
