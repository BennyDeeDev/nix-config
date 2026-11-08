# NixOS on Raspberry Pi 5

Build and flash the generic Raspberry Pi bootstrap SD image, enroll the Pi's
age key, then deploy `pi5-server`. The same AArch64 image also boots a Pi 3B+.

## Services

| Service | Port | Accessible at |
| --- | ---: | --- |
| Home Assistant | 8123 | <https://ha.benjaminderksen.com> |
| Immich | 2283 | <https://immich.benjaminderksen.com> |
| Vaultwarden | 8222 | <https://vault.benjaminderksen.com> |
| Gatus | 8080 | <https://status.benjaminderksen.com> |
| Beszel Hub | 8090 | <https://stats.benjaminderksen.com> |
| ntfy | 8060 | <https://ntfy.benjaminderksen.com> |
| OTBR UI and REST | 8082 / 8081 | <https://otbr.benjaminderksen.com> (Basic Auth); REST remains loopback-only |
| Matter.js UI and WebSocket API | 5580 | <https://matter.benjaminderksen.com> (Basic Auth); Home Assistant uses `ws://localhost:5580/ws` |
| Blocky DNS | 53 | `192.168.178.52:53` |
| PostgreSQL | Unix socket | Pi only |

## Prerequisites

- A Linux build machine that can build `aarch64-linux` outputs, either natively
  or through a remote builder or emulation. The desktop enables emulation in
  [`profiles/nixos-desktop/boot.nix`](../../profiles/nixos-desktop/boot.nix).
  This runs ARM binaries under emulation; it is not cross-compilation.
- The private SSH key matching the public key in
  [`profiles/pi/users.nix`](../../profiles/pi/users.nix).
- An enrolled YubiKey for rekeying the secrets.

Run build and deployment commands from the checkout root on the build machine.

```bash
export NIX_CONFIG='extra-experimental-features = nix-command flakes'
```

## Bootstrap and deploy

### 1. Build the bootstrap SD image

```bash
nix build .#images.pi-bootstrap
zstd -d -f result/sd-image/*.img.zst -o pi-bootstrap.img
```

### 2. Flash and boot

Use `lsblk` to identify the SD card. Replace `/dev/sdX` with its device path:

```bash
sudo umount /dev/sdX1
sudo umount /dev/sdX2
sudo dd \
  if=pi-bootstrap.img \
  of=/dev/sdX \
  bs=4M \
  status=progress \
  conv=fsync
sync
udisksctl power-off -b /dev/sdX
```

Insert the card, connect Ethernet, and boot the Pi. The generic bootstrap
hostname is `pi`. Connect using the authorized SSH key:

```bash
ssh benjamin@pi.fritz.box
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
`shared.yaml`, `shared-server.yaml`, and `pi5-server.yaml`. Rekey those files
with an enrolled YubiKey:

```bash
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/identity.txt"
nix run nixpkgs#sops -- updatekeys secrets/shared.yaml
nix run nixpkgs#sops -- updatekeys secrets/shared-server.yaml
nix run nixpkgs#sops -- updatekeys secrets/pi5-server.yaml
```

Commit `.sops.yaml` and the encrypted files together. For editing before
Home Manager has created `identity.txt`, use the
[bootstrap identity instructions](../../secrets/README.md#before-first-activation).

### 4. Deploy the server

From the updated checkout on the build machine:

```bash
nixos-rebuild switch --flake .#pi5-server \
  --target-host benjamin@pi.fritz.box \
  --build-host benjamin@pi.fritz.box \
  --sudo
```

The Pi builds the configuration and activates it using bootstrap sudo. Its
hostname changes to `pi5-server`; subsequent connections use
`pi5-server.fritz.box`.

The Home Assistant instructions below apply to `pi5-server`.

## Rebuild the server

From the checkout on the build machine:

```bash
nixos-rebuild switch --flake .#pi5-server \
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

## Service setup

### Cloudflare API token

Create a custom Cloudflare API token scoped to the `benjaminderksen.com` zone
with **Zone → DNS → Edit** and **Zone → Zone → Read** permissions. Store it
under the existing `cloudflare-api-token` key in `secrets/pi5-server.yaml`:

```bash
nix run nixpkgs#sops -- secrets/pi5-server.yaml
```

Follow the [SOPS setup](../../secrets/README.md#edit-a-secret) to configure the
age identity first. Do not put the token in Nix source or use a Global API Key.

### Beszel Hub

After deploying the Hub, open <https://stats.benjaminderksen.com> and create the
initial admin account if needed.

#### Enroll an agent

Repeat these steps for each NixOS host:

1. In Beszel, choose **Add System → Binary**. Enter the system name and its
   reachable host/IP; leave the port at `45876`.
2. Store that system's unique `TOKEN` in `secrets/<host>.yaml`:

   ```yaml
   beszel-agent-token: <system TOKEN>
   ```

3. Edit the encrypted file using the
   [SOPS workflow](../../secrets/README.md#edit-a-secret), then click **Add
   System**.
4. Set `my.beszel.agent.hubUrl` and `tokenSopsFile` for the host,
   then deploy it.

For `pi5-router`, use its reachable address `192.168.178.2` and store the
router's unique agent token as `beszel-agent-token` in
`secrets/pi5-router.yaml`.

The Hub's public `KEY` is configured once in `modules/beszel-agent.nix`; it is
not a secret. Use a different `TOKEN` for every system. Agents connect to the
Hub over WebSocket with SSH disabled, so do not open port `45876`.

#### Set up outage push notifications

1. Sign up at [Healthchecks.io](https://healthchecks.io/) and create a check
   for the service you want to monitor. Set a **Simple** schedule with a
   **1-minute period** and **2-minute grace time**.
2. Open the ntfy app or [ntfy.sh](https://ntfy.sh/app) and subscribe to a
   hard-to-guess topic. The public service is free to use without an account.
3. In Healthchecks.io, add the **ntfy** integration to the project, enter the
   same topic, and choose the down/up notification priorities. Test the
   integration and enable it for the check.
4. Copy the check's UUID into `secrets/pi5-server.yaml`:

   ```yaml
   healthchecks_uuid: "YOUR-UUID"
   ```

   This setup uses the check UUID; a project Ping Key is not needed.
5. Deploy the NixOS configuration. The Hub pings
   `https://hc-ping.com/<uuid>` with GET every 60 seconds. Healthchecks.io
   sends a push notification through ntfy if the Hub misses its check-in; with
   the schedule above, it reports down about three minutes after the last ping.

This uses one check on Healthchecks.io's free tier and the free public ntfy.sh
service.

Beszel's own system notifications are separate. Configure ntfy under
**Settings → Notifications** using
the existing `ntfy-topic` value from `secrets/pi5-server.yaml`, in a URL like
`ntfy://ntfy.benjaminderksen.com/<ntfy-topic>`.
Once agents are connected, enable the **Status** alert for each system in the
systems table.

### 1. Set up Home Assistant

Open <https://ha.benjaminderksen.com> and complete onboarding if no previous
configuration was restored.

### Configure Home Assistant's HTTP server

Open **Settings → System → Network → HTTP server** and set:

- **Listen addresses:** `127.0.0.1`
- **Server port:** `8123`
- **Trust X-Forwarded-For:** enabled
- **Trusted proxies:** `127.0.0.1`

Save the settings and accept any restart prompt.

If Caddy returns `400 Bad Request` and the UI is inaccessible through HTTPS,
open a temporary SSH tunnel from a client on the LAN:

```bash
ssh -N -L 8124:127.0.0.1:8123 benjamin@pi5-server.fritz.box
```

While that command is running, open `http://localhost:8124` and correct the HTTP
server settings in the UI.

Under **Settings → Devices & Services → Add Integration**, add:

- **OpenThread Border Router**, using `http://localhost:8081` if it
  is not discovered automatically.
- **Matter**, using `ws://localhost:5580/ws` if prompted for a server URL.

### 2. Import the Apple Thread network

To join the existing network managed by the HomePod minis:

1. Install the Home Assistant Companion app on the iPhone and connect it to
   `https://ha.benjaminderksen.com`.
2. In the app, open **Settings → Devices & Services → Thread → Configure**
   and select **Send credentials to Home Assistant**.
3. In the browser, open the Thread integration's configuration, select the
   imported Apple network, and choose **Make preferred network**.

### 3. Apply the dataset to OTBR

If OTBR remains on its own network after importing the credentials, read the
Apple dataset from Home Assistant's storage:

```bash
sudo cat /var/lib/hass/.storage/thread.datasets | grep -A2 iOS-app
```

Copy the `tlv` field for the Apple network. Replace `APPLE_DATASET_TLV` below
with that hex string:

```bash
dataset='APPLE_DATASET_TLV'
sudo ot-ctl thread stop
sudo ot-ctl dataset set active "$dataset"
sudo ot-ctl thread start
```

Wait about a minute, then check the network name, PAN ID, and router and
neighbor tables against the expected Apple network:

```bash
sudo ot-ctl state
sudo ot-ctl networkname
sudo ot-ctl panid
sudo ot-ctl router table
sudo ot-ctl neighbor table
```

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
