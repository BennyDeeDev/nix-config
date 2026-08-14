# NixOS on Raspberry Pi 5

Build the bootstrap SD image, flash it, boot the Pi, then deploy a role
(`pi5-server` or `pi5-kiosk`) remotely with `nixos-rebuild`.

## Prerequisites (build box)

The build machine must register binfmt for aarch64 so it can cross-compile.
On the desktop host in this repo this is already set via
`boot.binfmt.emulatedSystems = [ "aarch64-linux" ]` in
`nix/hosts/desktop/default.nix`.

## Build the bootstrap SD image

From the cross-compile build box (your desktop):

```bash
nix build .#images.pi5-bootstrap
zstd -d result/sd-image/*.img.zst -o pi5-bootstrap.img
sudo dd if=pi5-bootstrap.img of=/dev/sdX bs=4M status=progress conv=fsync
```

Replace `/dev/sdX` with the SD card device — verify with `lsblk` first.

## First boot

The bootstrap image sets `hostName = "pi5"`, runs sshd with password
authentication disabled, and provisions the SSH public key from
`nix/modules/pi5.nix` into the `benjamin` user's `authorized_keys`. SSH in
from any host holding the matching private key:

```bash
ssh ssh benjamin@pi5.fritz.box
```

`benjamin` is in `wheel`; sudo prompts for the user password (set via
`/etc/nixos/password-hash` on the host).

## Sops age key enrollment

On first boot, `sops.age.generateKey = true` writes
`/var/lib/sops-nix/key.txt` on the SD card, but decryption of
`benjamin-password` fails because the Pi's age pubkey isn't listed in
`.sops.yaml` yet. The bootstrap image sets
`security.sudo.wheelNeedsPassword = false` so you can still run `sudo` to
extract the pubkey even though the real password isn't usable yet
(`hashedPasswordFile` can't decrypt, so the password login path is broken
until enrollment completes).

After SSH'ing in via your authorized key, print the Pi's age pubkey:

```sh
sudo nix shell nixpkgs#age -c age-keygen -y /var/lib/sops-nix/key.txt
```

Back on your desktop, add the printed `age1...` string to `.sops.yaml` as
a new anchor (e.g. `- &pi5 age1...`) and append `*pi5` to the `age:`
recipients under `nix/secrets/common.yaml`'s `creation_rules`. Then
re-encrypt the file to the expanded recipient set and commit:

```sh
sops updatekeys nix/secrets/common.yaml
git add .sops.yaml nix/secrets/common.yaml
git commit
```

## Deploy a role configuration

First-time role switch (bootstrap still running):

```bash
nixos-rebuild switch --flake .#pi5-server \
  --target-host benjamin@pi5.fritz.box \
  --build-host benjamin@pi5.fritz.box \
  --sudo
```

Subsequent rebuilds (role config now running):

```bash
nixos-rebuild switch --flake .#pi5-server \
  --target-host benjamin@pi5.fritz.box \
  --build-host benjamin@pi5.fritz.box \
  --sudo --ask-sudo-password
```

## Flash ZBT-2 to OpenThread firmware (one-time, host-agnostic)

The ZBT-2 ships with EmberZNet (Zigbee) firmware. To use it as a Thread radio
in HA's OpenThread Border Router, flash OpenThreadRCP firmware. The firmware
persists in the chip — flash once on any machine, then move the stick to the Pi.

### Procedure (macOS)

1. Plug ZBT-2 into the macOS host via the USB extension cable.
2. Open Chromium/Chrome (not Firefox — WebSerial unsupported) and navigate to
   https://toolbox.openhomefoundation.org/home-assistant-connect-zbt-2/install/
3. Click **Connect** and select the ZBT-2 in the browser's serial port picker.
4. Choose **Thread** as the target firmware.
5. Click install and wait for completion.
6. Unplug and re-plug the stick.

### Note on Linux desktops

The web flasher fails on NixOS (and most Linux distros) because serial device
nodes are owned by `root:dialout` (or `root:uucp`) at mode `0660`, and Chrome
running as a regular user hits `EACCES` on the `open()` syscall. Observed
behaviour: log truncates after `Opening a serial connection at 115200 baud`
and never advances to probing. macOS has no equivalent gating, hence the Mac
being the working path here.

Workarounds if a Mac is not available:
- `sudo chmod 666 /dev/ttyACM0` (temporary; reverts on replug)
- OR `sudo usermod -aG dialout $USER` then fully log out and back in
- OR bypass the browser entirely:
  ```
  nix-shell -p python311Packages.universal-silabs-flasher
  universal-silabs-flasher --device /dev/serial/by-id/usb-Nabu_Casa...ZBT-2...-if00 probe
  universal-silabs-flasher --device /dev/serial/by-id/usb-Nabu_Casa...ZBT-2...-if00 \
    flash --firmware <otbr-rcp.gbl> --allow-cross-flashing
  ```
  (Firmware .gbl from https://github.com/NabuCasa/silabs-firmware-builder/releases
  under "OpenThreadRCP" — pick the EFR32MG24 build for ZBT-2.)

## Home Assistant + Thread + Matter

1. Browse to `http://pi5-server.fritz.box:8123` and complete the HA
   onboarding wizard (admin user, location). State persists in HA's
   `.storage/`.

2. Add the Matter integration in HA: Settings → Devices & Services →
   Add Integration → search "Matter". HA auto-discovers the matter-server
   WebSocket at `ws://localhost:5580/ws` (both containers share the host
   netns). If prompted for a URL, enter it manually.

3. Import Apple HomeKit Thread credentials so the OTBR joins your existing
   Apple Thread network (HomePod minis are the existing border routers)
   instead of staying on its own partition:

   - Install the HA Companion app on your iPhone.
   - Connect it to `http://pi5-server.fritz.box:8123`.
   - In the app: Settings → Devices & Services → Thread → Configure →
     **Send credentials to Home Assistant**.
   - Back in HA (browser): Settings → Devices & Services → Thread →
     Configure → mark the Apple network (`MyHome...`) as
     **Make preferred network**.

4. Make the OTBR actually join Apple's Thread mesh. HA now has the Apple
   dataset, but the OTBR container is still `leader` of its own partition.
   Pull the dataset from HA's storage and inject it into OTBR:

   ```bash
   # Read the Apple dataset TLV from HA's storage
   sudo cat /var/lib/homeassistant/.storage/thread.datasets | grep -A2 iOS-app
   # (the "tlv" field is the hex blob)

   # Stop OTBR's own partition, set the Apple dataset, restart Thread
   sudo podman exec otbr ot-ctl thread stop
   sudo podman exec otbr ot-ctl dataset set active <apple-dataset-tlv-hex>
   sudo podman exec otbr ot-ctl thread start
   ```

   Wait ~60 seconds, then verify OTBR joined Apple's mesh:

   ```bash
   sudo podman exec otbr ot-ctl state
   sudo podman exec otbr ot-ctl networkname 
   sudo podman exec otbr ot-ctl panids
   sudo podman exec otbr ot-ctl router table
   sudo podman exec otbr ot-ctl neighbor table
   ```

   The dataset persists in `/var/lib/otbr/thread/` across container
   restarts, so this step is one-time.

5. Commission a Matter-over-Thread device into HA (multi-admin — the
   device stays paired to Apple Home, HA joins as a second controller):

   - In Apple Home: select the device → open its commissioning window
     (Pairing Mode).
   - Enter the device's setup code.
   - HA discovers the device via mDNS and commissions it into HA's fabric.