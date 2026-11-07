# Desktop NixOS installation

Install the `desktop` configuration, then enable Secure Boot with Lanzaboote.
Boot the NixOS graphical ISO with Secure Boot disabled. On this MSI board,
`F11` opens the boot menu and `Del` opens the firmware settings.

## Disk layout

[`disko.nix`](disko.nix) formats both SSDs, identified by their serial numbers:

| Disk | Serial | Layout |
| --- | --- | --- |
| Samsung 990 PRO with Heatsink 1 TB | `S7HFNJ0Y704719Z` | 1 GB ESP at `/boot`, remaining space as Btrfs |
| Samsung 990 PRO 1 TB | `S7HDNJ0Y413952T` | Btrfs at `/mnt/games` |

The system disk has Btrfs subvolumes `/root` → `/`, `/home` → `/home`,
`/log` → `/var/log`, and `/nix` → `/nix`.

Confirm both drives before running Disko:

```bash
lsblk -o NAME,SIZE,SERIAL
```

## Install

Enable the Nix command and flakes for this shell:

```bash
export NIX_CONFIG='extra-experimental-features = nix-command flakes'
```

### 1. Clone the repository

From a terminal in the live system:

```bash
nix run nixpkgs#git -- clone https://github.com/BennyDeeDev/nix-config /tmp/nix-config
```

### 2. Partition and mount

This destroys the contents of both disks listed above:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:nix-community/disko/latest -- \
  --mode destroy,format,mount \
  /tmp/nix-config/hosts/desktop/disko.nix
```

### 3. Generate the hardware configuration

```bash
sudo nixos-generate-config --no-filesystems --root /mnt
sudo cp /mnt/etc/nixos/hardware-configuration.nix /tmp/nix-config/hosts/desktop/
```

Disko provides the filesystems. [`hardware.nix`](hardware.nix) already sets
`neededForBoot` for `/var/log`; no filesystem edits are needed in the generated
file.

### 4. Enroll the system age key

Create the key inside the mounted installation before installing. Skip key
generation if you restored an existing key at this path:

```bash
sudo mkdir -p /mnt/var/lib/sops-nix
sudo nix --extra-experimental-features 'nix-command flakes' \
  shell nixpkgs#age --command age-keygen -o /mnt/var/lib/sops-nix/key.txt
```

Print its public key:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  shell nixpkgs#age --command age-keygen -y /mnt/var/lib/sops-nix/key.txt
```

On an editing machine with an enrolled YubiKey, replace the `&desktop` public
key in `.sops.yaml` and rekey the desktop-accessible files:

```bash
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/identity.txt"
nix run nixpkgs#sops -- updatekeys secrets/shared.yaml
nix run nixpkgs#sops -- updatekeys secrets/shared-desktop.yaml
nix run nixpkgs#sops -- updatekeys secrets/desktop.yaml
```

Commit and push those changes, then pull them into the installer's checkout:

```bash
nix run nixpkgs#git -- -C /tmp/nix-config pull --ff-only
```

The generated hardware file remains a local change. If editing from the live
system instead, follow the
[YubiKey identity instructions](../../secrets/README.md#before-first-activation).

### 5. Install and preserve the checkout

```bash
sudo nixos-install --flake /tmp/nix-config#desktop --root /mnt
sudo cp -a /tmp/nix-config /mnt/etc/nixos/nix-config
sudo reboot
```

The installed system key decrypts the user password and NAS credentials.
The checkout copy preserves the generated hardware file across the reboot.

### 6. Finish setup after boot

Log in as `benjamin` and move the saved checkout to the path used by the
rebuild aliases:

```bash
mkdir -p ~/Repos
sudo cp -a /etc/nixos/nix-config ~/Repos/nix-config
sudo chown -R "$USER:users" ~/Repos/nix-config
cd ~/Repos/nix-config
```

Review and commit `hosts/desktop/hardware-configuration.nix`.

Home Manager uses a separate age key for home secrets. Print its public key:

```bash
nix shell nixpkgs#age --command age-keygen -y ~/.config/sops/age/keys.txt
```

Replace `&desktop-hm` in `.sops.yaml` and rekey `shared.yaml`,
`shared-desktop.yaml`, and `desktop-hm.yaml` as in step 4. If the key has not
been generated yet, use the
[host enrollment instructions](../../secrets/README.md#1-obtain-the-host-public-key).
Rebuild after enrolling it:

```bash
sudo nixos-rebuild switch --flake .#desktop
```

## Secure Boot

[`profiles/nixos-desktop/boot.nix`](../../profiles/nixos-desktop/boot.nix)
configures Lanzaboote to generate keys under `/var/lib/sbctl` and enroll them
alongside Microsoft's keys when the firmware enters Setup Mode. Enrollment
is configured to reboot automatically.

### 1. Install the signed bootloader

From the checkout:

```bash
sudo nixos-rebuild boot --install-bootloader --flake .#desktop
sudo sbctl verify
```

Use `--install-bootloader` when replacing an existing unsigned bootloader.
Check that the installed generation images, `BOOTX64.EFI`, and
`systemd-bootx64.efi` are signed. Intermediate `kernel-*.efi` files may be
reported as unsigned; firmware does not load those directly.

### 2. Configure the MSI firmware

Reboot, press `Del`, and switch to Advanced mode with `F7`:

1. Under **Security → Secure Boot**, set **Secure Boot** to **Enabled**,
   **Secure Boot Mode** to **Custom**, and **Secure Boot Preset** to
   **Maximum Security**.
2. Under **Key Management**, disable **Provision Factory Default keys**.
   Save and exit with `F10`.
3. Re-enter the firmware settings before the OS boots.
4. Under **Key Management**, select **Delete all Secure Boot variables**.
   Confirm the delete and reset prompts.
5. Let the system boot and complete automatic key enrollment and its reboot.

### 3. Verify enforcement

```bash
sudo sbctl status
sudo sbctl verify
bootctl status
```

Expected: **Secure Boot: Enabled**, **Setup Mode: Disabled**, with the local
keys and Microsoft's keys enrolled. The reported vendor keys include
`microsoft builtin-db builtin-KEK builtin-PK`.

## WireGuard to the router

[`wireguard.nix`](wireguard.nix) configures the desktop's `wg0` as a declarative
NetworkManager profile, using `networking.networkmanager.ensureProfiles`. The
SOPS-backed environment file supplies the private key at runtime; it is not
stored in the Nix store. The profile has autoconnect disabled so it can be
toggled from Plasma's network tray widget. This host feature contains the
profile and its SOPS wiring. The client has address
`10.77.30.2/32`, DNS `10.77.30.1`, endpoint `192.168.178.2:51820`, and
`AllowedIPs = 0.0.0.0/0`. NetworkManager installs IPv4 full-tunnel policy
routing when the profile is connected; more-specific local routes still take
precedence.

Create the host's `wireguard-private-key` entry as described under
[WireGuard secrets](../../secrets/README.md#wireguard-secrets). Put the desktop
public key in the router's `hosts/pi5-router/wireguard.nix` peer, and the
router's `wg0` public key in this host's `wireguard.nix`. The feature is
imported by `default.nix`; rebuild normally after deploying the router.

IPv6 routing and leak prevention are deferred. IPv6 may use the physical
connection while this IPv4-only tunnel is connected. The tunnel does not
autoconnect. Use the KDE system-tray network widget to connect or disconnect
`wg0`, or use:

```bash
nmcli connection up wg0
nmcli connection down wg0
```

Stopping the tunnel restores ordinary IPv4 routes and DNS; this is not a kill
switch. The endpoint is only reachable from the home LAN with the current
private address and no port forwarding. Inspect `ip -4 rule` and
`ip -4 route show table all`, rather than just the main default route, to
verify routing. Follow the
[router validation guide](../pi5-router/README.md#client-configuration-and-local-validation)
for handshake, DNS, network-access, and internet-egress checks. Neither VPN
is reachable from outside home with the current private endpoint and no
Fritz!Box port forwarding. macOS configuration is not included.
