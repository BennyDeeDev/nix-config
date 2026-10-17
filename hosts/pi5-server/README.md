# NixOS on Raspberry Pi 5

Build and flash the bootstrap SD image, enroll the Pi's age key, then deploy
`pi5-server`.

## Prerequisites

- A Linux build machine that can build `aarch64-linux` outputs, either natively
  or through a remote builder or emulation. The desktop enables emulation in
  [`profiles/nixos-desktop/boot.nix`](../../profiles/nixos-desktop/boot.nix).
  This runs ARM binaries under emulation; it is not cross-compilation.
- The private SSH key matching the public key in
  [`profiles/pi5/users.nix`](../../profiles/pi5/users.nix).
- An enrolled YubiKey for rekeying the secrets.

Run build and deployment commands from the checkout root on the build machine.

```bash
export NIX_CONFIG='extra-experimental-features = nix-command flakes'
```

## Bootstrap and deploy

### 1. Build the bootstrap SD image

```bash
nix build .#images.pi5-bootstrap
nix run nixpkgs#zstd -- -d result/sd-image/*.img.zst -o pi5-bootstrap.img
```

### 2. Flash and boot

Use `lsblk` to identify the SD card. Replace `/dev/sdX` with its device path:

```bash
sudo dd \
  if=pi5-bootstrap.img \
  of=/dev/sdX \
  bs=4M \
  status=progress \
  conv=fsync
sync
```

Insert the card, connect Ethernet, and boot the Pi. The bootstrap hostname is
`pi5`. Connect using the authorized SSH key:

```bash
ssh benjamin@pi5.fritz.box
```

Password authentication is disabled. The bootstrap image allows passwordless
sudo; the deployed server requires the user's password for sudo.

### 3. Enroll the age key

The first boot generates `/var/lib/sops-nix/key.txt`. Secret decryption may
fail until this key is enrolled, but bootstrap sudo does not need the password
stored in those secrets.

On the Pi, print its public key:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  shell nixpkgs#age --command age-keygen -y /var/lib/sops-nix/key.txt
```

On the editing machine, replace the `&pi5-server` public key in `.sops.yaml`
with the printed `age1...` value. Its alias is already listed in the rules for
`common.yaml` and `pi5-server.yaml`. Rekey both files with an enrolled YubiKey:

```bash
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/identity.txt"
nix run nixpkgs#sops -- updatekeys secrets/common.yaml
nix run nixpkgs#sops -- updatekeys secrets/pi5-server.yaml
```

Commit `.sops.yaml` and both encrypted files together. For editing before
Home Manager has created `identity.txt`, use the
[bootstrap identity instructions](../../secrets/README.md#before-first-activation).

### 4. Deploy the server

From the updated checkout on the build machine:

```bash
nix run nixpkgs#nixos-rebuild -- switch \
  --flake .#pi5-server \
  --target-host benjamin@pi5.fritz.box \
  --build-host benjamin@pi5.fritz.box \
  --sudo
```

The Pi builds the configuration and activates it using bootstrap sudo. Its
hostname changes to `pi5-server`; subsequent connections use that name.

The same bootstrap image can deploy `pi5-kiosk` by changing the flake output.
That host is still a placeholder; the Home Assistant instructions below apply
to `pi5-server`.

## Rebuild the server

From the checkout on the build machine:

```bash
nix run nixpkgs#nixos-rebuild -- switch \
  --flake .#pi5-server \
  --target-host benjamin@pi5-server.fritz.box \
  --build-host benjamin@pi5-server.fritz.box \
  --sudo \
  --ask-sudo-password
```

## Flash the ZBT-2 for Thread

Flash OpenThread RCP firmware before using the ZBT-2 with OTBR. Firmware stays
on the radio, so this can be done on another machine before connecting it to
the Pi.

### Browser flasher

1. Connect the ZBT-2 with its USB extension cable.
2. Open the [ZBT-2 flasher][zbt2-flasher] in Chrome or Chromium. Firefox does
   not support the required Web Serial API.
3. Click **Connect** and select the ZBT-2.
4. Select **Thread**, install the firmware, then unplug and reconnect the radio.
5. Connect it to the Pi. If using a different stick, update the serial device
   path in [`home-assistant.nix`](home-assistant.nix).

### Linux serial permissions

If flashing stops at `Opening a serial connection at 115200 baud`, check that
the browser user can open the serial device. This can be a permissions issue,
not a failure of the flasher on Linux.

For a temporary fix, replace `/dev/ttyACM0` with the radio's device:

```bash
sudo chmod 666 /dev/ttyACM0
```

Reconnect in the browser and retry. The permission change is lost when the
device is unplugged. For persistent access, add the user to the device's owning
group (`dialout` or `uucp`, depending on the system). On NixOS, declare the
group in the user's configuration, rebuild, then log out and back in.

### Command-line flasher

Download the OpenThread RCP `.gbl` built for ZBT-2 from the
[firmware releases][silabs-firmware]. Replace the device path and
`zbt2-openthread.gbl` with the radio and downloaded file:

```bash
nix run nixpkgs#python3Packages.universal-silabs-flasher -- \
  --device /dev/ttyACM0 \
  probe

nix run nixpkgs#python3Packages.universal-silabs-flasher -- \
  --device /dev/ttyACM0 \
  flash \
  --profile zbt2 \
  --firmware zbt2-openthread.gbl
```

The command-line flasher also needs access to the serial device.

## Home Assistant, Thread, and Matter

The containers and radio settings are defined in
[`home-assistant.nix`](home-assistant.nix). Run the Podman commands below on
the Pi.

### 1. Set up Home Assistant

Open `http://pi5-server.fritz.box:8123` and complete onboarding if no previous
configuration was restored. Home Assistant stores its configuration under
`/var/lib/homeassistant`.

Under **Settings → Devices & Services → Add Integration**, add:

- **OpenThread Border Router**, using `http://localhost:8081` if it is not
  discovered automatically.
- **Matter**, using `ws://localhost:5580/ws` if prompted for a server URL.

All three containers use host networking, so Home Assistant can reach the
other two through `localhost`.

### 2. Import the Apple Thread network

To join the existing network managed by the HomePod minis:

1. Install the Home Assistant Companion app on the iPhone and connect it to
   `http://pi5-server.fritz.box:8123`.
2. In the app, open **Settings → Devices & Services → Thread → Configure**
   and select **Send credentials to Home Assistant**.
3. In the browser, open the Thread integration's configuration, select the
   imported Apple network, and choose **Make preferred network**.

### 3. Apply the dataset to OTBR

If OTBR remains on its own network after importing the credentials, read the
Apple dataset from Home Assistant's storage:

```bash
sudo cat /var/lib/homeassistant/.storage/thread.datasets | grep -A2 iOS-app
```

Copy the `tlv` field for the Apple network. Replace `APPLE_DATASET_TLV` below
with that hex string:

```bash
dataset='APPLE_DATASET_TLV'
sudo podman exec otbr ot-ctl thread stop
sudo podman exec otbr ot-ctl dataset set active "$dataset"
sudo podman exec otbr ot-ctl thread start
```

Wait about a minute, then check the network name, PAN ID, and router and
neighbor tables against the expected Apple network:

```bash
sudo podman exec otbr ot-ctl state
sudo podman exec otbr ot-ctl networkname
sudo podman exec otbr ot-ctl panid
sudo podman exec otbr ot-ctl router table
sudo podman exec otbr ot-ctl neighbor table
```

OTBR state persists under `/var/lib/otbr`, mounted as `/data` in the container.

### 4. Add a Matter device

For a device already paired with Apple Home:

1. Open the device in Apple Home and enable its pairing mode to obtain a
   sharing code.
2. In the Home Assistant Companion app, add a Matter device that is already
   in use and enter that code.
3. Complete commissioning. The device stays paired with Apple Home and also
   becomes available in Home Assistant.

[zbt2-flasher]: https://toolbox.openhomefoundation.org/home-assistant-connect-zbt-2/install/
[silabs-firmware]: https://github.com/NabuCasa/silabs-firmware-builder/releases
