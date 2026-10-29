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
zstd -d -f result/sd-image/*.img.zst -o pi5-bootstrap.img
```

### 2. Flash and boot

Use `lsblk` to identify the SD card. Replace `/dev/sdX` with its device path:

```bash
sudo umount /dev/sdX1
sudo umount /dev/sdX2
sudo dd \
  if=pi5-bootstrap.img \
  of=/dev/sdX \
  bs=4M \
  status=progress \
  conv=fsync
sync
udisksctl power-off -b /dev/sdX
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
nixos-rebuild switch --flake .#pi5-server \
  --target-host benjamin@pi5.fritz.box \
  --build-host benjamin@pi5.fritz.box \
  --sudo
```

The Pi builds the configuration and activates it using bootstrap sudo. Its
hostname changes to `pi5-server`; subsequent connections use
`pi5-server.fritz.box`.

The same bootstrap image can deploy `pi5-kiosk` by changing the flake output.
That host is still a placeholder; the Home Assistant instructions below apply
to `pi5-server`.

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

## Home Assistant, Thread, Matter, Vaultwarden, and Immich

Home Assistant, OTBR, Matter.js, Vaultwarden, and Immich are configured as
native NixOS services in [`home-assistant.nix`](home-assistant.nix),
[`caddy.nix`](caddy.nix),
[`openthread-border-router.nix`](openthread-border-router.nix),
[`matterjs-server.nix`](matterjs-server.nix),
[`vaultwarden.nix`](vaultwarden.nix), and [`immich.nix`](immich.nix). The shared
PostgreSQL service and its cluster backup are declared in
[`postgresql.nix`](postgresql.nix).

### Blocky and local DNS

The Pi continues to receive its network configuration from the FRITZ!Box DHCP
server. Blocky is configured in [`blocky.nix`](blocky.nix), listens on IPv4
interfaces, and does not run a DHCP server. It forwards `*.fritz.box` queries
to the FRITZ!Box and maps `ha.benjaminderksen.com`,
`immich.benjaminderksen.com`, and `vault.benjaminderksen.com` to the Pi's LAN
address, `192.168.178.52`. Reserve that address for the Pi in the FRITZ!Box DHCP
settings so the local DNS records stay correct. Other DNS queries use Quad9 over
DNS-over-HTTPS, with Quad9's IPv4 addresses as bootstrap resolvers. Blocky has
no web dashboard.

To test DNS resolution on the Pi:

```bash
ssh benjamin@pi5-server.fritz.box
nslookup ha.benjaminderksen.com 127.0.0.1
nslookup immich.benjaminderksen.com 127.0.0.1
nslookup vault.benjaminderksen.com 127.0.0.1
```

### 1. Set up Home Assistant

Open `https://ha.benjaminderksen.com` and complete onboarding if no previous
configuration was restored. Caddy proxies to Home Assistant on loopback and
uses the wildcard certificate managed by NixOS ACME with Cloudflare DNS
validation. DNS validation does not require exposing Home Assistant to the
internet. Home Assistant stores its runtime state under `/var/lib/hass`.

### Immich

Immich is served at `https://immich.benjaminderksen.com` through Caddy with the
existing wildcard certificate. It listens on `127.0.0.1:2283`; Blocky maps the
hostname to the Pi for LAN clients. The native NixOS module uses the shared
PostgreSQL service, creates Immich's database and user, and enables machine
learning. The configured 8 GB of RAM matches Immich's recommendation.

Immich media is stored at the module's default `/var/lib/immich` location. The
PostgreSQL data directory is local to the Pi; do not place it on the NAS share.
Choose durable storage for the photo library before uploading a large
collection.

Each PostgreSQL Restic run starts `postgresqlBackup.service` first, which dumps
the full cluster (all databases and roles) to `/var/backup/postgresql`. The
separate dump timer is disabled. A failed dump prevents the Restic snapshot.
Restic stores the dumps in `/mnt/nas/restic/postgresql-restic`. A separate
Restic job backs up `/var/lib/immich` to `/mnt/nas/restic/immich-restic`,
stopping Immich during the snapshot. Both the database dump and media files are
needed for a complete Immich restore.

### Vaultwarden

Vaultwarden is served at `https://vault.benjaminderksen.com` through Caddy and
uses the existing wildcard certificate. The Vaultwarden service listens only
on `127.0.0.1:8222`; Blocky maps the hostname to the Pi for LAN clients.
Registration remains enabled so the first account can be created through the
web vault without an admin-token or SOPS bootstrap. Anyone on the LAN who can
reach this hostname can register, so keep the service LAN-only: do not publish
public DNS for it or forward HTTPS from the router to the Pi.

The web vault is built with an 8-character minimum master-password length. This
patch affects only the web vault; official mobile and desktop clients still
require 12 characters when creating or changing a password, though they can
use an existing shorter password. The Nix build fails if a future web-vault
update changes the source line being patched, so review the override when
updating Nixpkgs.

The Restic job backs up all of `/var/lib/vaultwarden` to
`/mnt/nas/restic/vaultwarden-restic`, stopping Vaultwarden during the backup.

### Cloudflare API token

Create a custom Cloudflare API token scoped to the `benjaminderksen.com` zone
with **Zone → DNS → Edit** and **Zone → Zone → Read** permissions. Store it
under the existing `cloudflare-api-token` key in `secrets/pi5-server.yaml`:

```bash
nix run nixpkgs#sops -- secrets/pi5-server.yaml
```

Follow the [SOPS setup](../../secrets/README.md#edit-a-secret) to configure the
age identity first. Do not put the token in Nix source or use a Global API Key.

### Configure Home Assistant's HTTP server

Home Assistant 2026.8 and later stores HTTP server settings in its UI. After
the HTTP settings have migrated, it ignores the legacy YAML `http` block. Open
**Settings → System → Network → HTTP server** and set:

- **Listen addresses:** `127.0.0.1`
- **Server port:** `8123`
- **Trust X-Forwarded-For:** enabled
- **Trusted proxies:** `127.0.0.1`

Save the settings and accept any restart prompt. The loopback listener means
clients must use `https://ha.benjaminderksen.com`; direct LAN access to port
8123 is intentionally unavailable. Once these UI settings are verified, remove
the legacy `config.http` block from [`home-assistant.nix`](home-assistant.nix).

If Caddy returns `400 Bad Request` and the UI is inaccessible through HTTPS,
open a temporary SSH tunnel from a client on the LAN:

```bash
ssh -N -L 8124:127.0.0.1:8123 benjamin@pi5-server.fritz.box
```

While that command is running, open `http://localhost:8124` and correct the HTTP
server settings in the UI.

Under **Settings → Devices & Services → Add Integration**, add:

- **OpenThread Border Router**, using `http://pi5-server.fritz.box:8081` if it
  is not discovered automatically.
- **Matter**, using `ws://localhost:5580/ws` if prompted for a server URL.

Home Assistant can reach OTBR and Matter.js through `localhost`.

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

OTBR state persists under `/var/lib/thread`.

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
