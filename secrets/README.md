# Secrets

[SOPS](https://github.com/getsops/sops) encrypts the YAML files in this
directory with age. YubiKeys are used for editing; host keys let
[sops-nix](https://github.com/Mic92/sops-nix) decrypt secrets unattended.

## Keys and files

| File | Purpose |
| --- | --- |
| `~/.config/sops/age/identity.txt` | YubiKey identity pointer for interactive SOPS commands |
| `/var/lib/sops-nix/key.txt` | NixOS age key for system secrets |
| `~/.config/sops/age/keys.txt` | Home Manager age key for home secrets |
| [`.sops.yaml`](../.sops.yaml) | Recipient rules for each encrypted file |
| `secrets/*.yaml` | Encrypted secrets, including their recipient metadata |

Both YubiKeys, `yk-5-nfc` and `yk-5c-nano`, are recipients of every encrypted
file. Hosts receive access through the matching rules in `.sops.yaml`.
Host-specific files without an `-hm` suffix are for NixOS; Home Manager files
use `-hm`, such as `desktop-hm.yaml`, `deck-hm.yaml`, and
`mbp-personal-hm.yaml`.

Enable the Nix command and flakes for this shell:

```bash
export NIX_CONFIG='extra-experimental-features = nix-command flakes'
```

## Edit a secret

Plug in the YubiKey selected by your Home Manager configuration:

```bash
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/identity.txt"

nix run nixpkgs#sops -- secrets/shared.yaml
```

Enter the PIN and touch the YubiKey when prompted. Save and close the editor
to re-encrypt the file. Commit the encrypted change.

### Before first activation

Before Home Manager creates `identity.txt`, interactive SOPS commands can use
the enrolled YubiKey pointer directly:

```bash
export SOPS_AGE_KEY='AGE-PLUGIN-YUBIKEY-1...'
```

Replace the placeholder with the pointer for your YubiKey. Clear it before
activation so it does not interfere with host-key decryption:

```bash
unset SOPS_AGE_KEY
```

## Remove a secret

With the YubiKey identity selected as above:

```bash
nix run nixpkgs#sops -- unset secrets/shared.yaml '["obsolete-key"]'
```

For nested keys, use a path such as `'["services"]["example"]["password"]'`.
Remove the corresponding Nix declaration and consumers, then commit the changes.

## Enroll a host

### 1. Obtain the host public key

For an existing NixOS system key:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  shell nixpkgs#age --command age-keygen -y /var/lib/sops-nix/key.txt
```

For an existing Home Manager key:

```bash
nix shell nixpkgs#age --command age-keygen -y ~/.config/sops/age/keys.txt
```

#### Missing host keys

sops-nix normally generates host keys during activation when secrets are
configured. To enroll before activation, create the missing key on the target
system, then print its public key using the commands above.

For NixOS:

```bash
sudo mkdir -p /var/lib/sops-nix

sudo nix --extra-experimental-features 'nix-command flakes' \
  shell nixpkgs#age --command age-keygen -o /var/lib/sops-nix/key.txt
```

From an installer, use the target's mounted path, such as
`/mnt/var/lib/sops-nix/key.txt`, including its parent directory.

For Home Manager:

```bash
mkdir -p ~/.config/sops/age

nix shell nixpkgs#age --command age-keygen -o ~/.config/sops/age/keys.txt
```

### 2. Update recipients

On the editing machine, add the printed `age1...` public key under `keys` in
`.sops.yaml`. Add its alias to each relevant creation rule:

```yaml
keys:
  - &example age1...
creation_rules:
  - path_regex: secrets/shared\.ya?ml$
    key_groups:
      - age:
          - *example
```

Merge these entries into the existing lists, keeping the other recipients.
When reinstalling a host, replace its existing public key instead.

### 3. Rekey the affected files

Editing `.sops.yaml` changes the rules, not existing encrypted files. Saving a
secret in SOPS preserves its existing recipients; `sops updatekeys` applies
the new rules. Decryption uses the metadata stored in each encrypted file.

Use an already enrolled YubiKey, with `SOPS_AGE_KEY_FILE` set as shown under
[Edit a secret](#edit-a-secret). Run `updatekeys` separately for each file whose
recipient list changed. For example, enrolling a Deck key requires:

```bash
nix run nixpkgs#sops -- updatekeys secrets/shared.yaml
nix run nixpkgs#sops -- updatekeys secrets/shared-desktop.yaml
nix run nixpkgs#sops -- updatekeys secrets/deck-hm.yaml
```

For a Pi server key, update `shared.yaml`, `shared-server.yaml`, and
`pi5-server.yaml`. For the Pi kiosk key, update `shared.yaml`,
`shared-server.yaml`, and `pi3-kiosk.yaml`. Commit `.sops.yaml` and the affected
encrypted files together. The base `pi5-router` needs `shared.yaml`; enabling
the router VPN uses `pi5-router.yaml`, and the desktop client uses
`desktop.yaml`; each file contains its host's `wireguard-private-key`. The
router file also holds the UI-managed VPN secrets. See
[WireGuard secrets](#wireguard-secrets) before first deployment or key rotation.

### 4. Activate again

Deploy the updated checkout and rebuild the host using its setup guide.
Activation decrypts secrets with the enrolled host key; it does not require
the YubiKey.

## WireGuard secrets

The router imports both VPN features. The desktop's `wg0` profile is declared
in `hosts/desktop/wireguard.nix` and is managed by NetworkManager. Keep private
keys in the existing host-specific SOPS files; do not create a separate
encrypted file for wg-access-server.

### 1. Generate three separate keypairs

Generate keys locally in `/dev/shm`, a RAM-backed temporary directory. Set a
restrictive umask **before creating the files** so their permissions are
private. These commands write private keys; never use `cat` to display them or
paste them into chat, Nix configuration, or plaintext Git files.

If you already generated these files before setting the umask, restrict their
permissions now (the umask does not change existing files):

```bash
chmod 600 /dev/shm/desktop-wg0.key /dev/shm/pi5-router-wg0.key \
  /dev/shm/pi5-router-wg1.key
```

For fresh keys, run:

```bash
umask 077
nix run nixpkgs#wireguard-tools -- genkey > /dev/shm/desktop-wg0.key
nix run nixpkgs#wireguard-tools -- genkey > /dev/shm/pi5-router-wg0.key
nix run nixpkgs#wireguard-tools -- genkey > /dev/shm/pi5-router-wg1.key
```

Check that each file is mode `600`:

```bash
stat -c '%a %n' /dev/shm/desktop-wg0.key /dev/shm/pi5-router-wg0.key \
  /dev/shm/pi5-router-wg1.key
```

The key files are deliberately distinct: the desktop client uses `wg0`, the
router has its own `wg0` server key, and wg-access-server owns the router's
`wg1` server key. Do not rerun the generation commands unless you intend to
replace those keys.

Print only the public keys. The labels identify where each corresponding
private key is used:

```bash
for name in desktop-wg0 pi5-router-wg0 pi5-router-wg1; do
  printf '%s public key: ' "$name"
  nix run nixpkgs#wireguard-tools -- pubkey < "/dev/shm/$name.key"
done
```

### 2. Store the private keys in SOPS

Select the enrolled YubiKey identity and edit the desktop secrets file:

```bash
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/identity.txt"
nix run nixpkgs#sops -- secrets/desktop.yaml
```

Set its `wireguard-private-key` value to the contents of
`/dev/shm/desktop-wg0.key`. Preserve all other entries.

Edit the router secrets file:

```bash
nix run nixpkgs#sops -- secrets/pi5-router.yaml
```

Set the root `wireguard-private-key` to the contents of
`/dev/shm/pi5-router-wg0.key`. In the existing `wg-access-server` block string,
set `wireguard.privateKey` to the contents of
`/dev/shm/pi5-router-wg1.key`. Preserve the admin password and other existing
values. If creating that block for the first time, its shape is:

```yaml
wireguard-private-key: <ROUTER_WG0_PRIVATE_KEY>
wg-access-server: |
  adminPassword: "<STRONG_UNIQUE_PASSWORD>"
  wireguard:
    privateKey: "<ROUTER_WG1_PRIVATE_KEY>"
  auth:
    sessionStore:
      secret: "<64_HEXADECIMAL_CHARACTERS>"
```

The `wg-access-server` value must remain a YAML block string (`|`), not a
nested mapping. sops-nix extracts it to the service's runtime secrets file;
the service does not receive the separate `wg0` key. Use a password manager
for the admin password. Generate the session secret locally with:

```bash
nix run nixpkgs#openssl -- rand -hex 32
```

Enter generated secrets directly into the SOPS editor; do not pass them as
command arguments or store them in shell history.

### 3. Put public keys in their peer configuration

- Put the public key derived from `desktop-wg0.key` in the router's desktop
  peer in `hosts/pi5-router/wireguard.nix` (`allowedIPs` remains
  `10.77.30.2/32`).
- Put the public key derived from `pi5-router-wg0.key` in the
  `wireguard-peer.<PUBLIC_KEY>` section name in
  `hosts/desktop/wireguard.nix`.
- wg-access-server derives its `wg1` public key from its SOPS private key and
  includes it in UI-generated client profiles. There is no static Nix peer
  entry for that key. Rotating `wg1` means updating/re-importing its clients.

Only public keys go in Nix configuration. Never add per-device UI client
private keys to Nix or SOPS; keep exported profiles private.

### 4. Validate, deploy, and clean up

Build the affected configurations before activating them. Deploy the router
before switching the desktop profile; keep local recovery access available
while rotating a key because the tunnel will be interrupted. Commit the
encrypted SOPS files and public-key configuration changes, but never the
plaintext keys.

After both systems are working, remove the temporary private-key files:

```bash
rm /dev/shm/desktop-wg0.key /dev/shm/pi5-router-wg0.key \
  /dev/shm/pi5-router-wg1.key
```

The router guide covers validation and the desktop guide covers manual
NetworkManager activation:
[router](../hosts/pi5-router/README.md#client-configuration-and-local-validation),
[desktop](../hosts/desktop/README.md#wireguard-to-the-router).

## Set up a YubiKey

### 1. Configure PIV access

On a new or factory-reset YubiKey, the default PIN is `123456` and the PUK is
`12345678`.

```bash
nix run nixpkgs#yubikey-manager -- piv access change-pin
nix run nixpkgs#yubikey-manager -- piv access change-puk

nix run nixpkgs#yubikey-manager -- piv access change-management-key \
  -a TDES \
  --generate \
  --protect
```

Use TDES for
[plugin compatibility](https://github.com/str4d/age-plugin-yubikey/issues/92).
`--protect` stores the generated management key protected by the PIN.

### 2. Generate and register the age identity

```bash
nix run nixpkgs#age-plugin-yubikey -- --generate
```

Generation defaults to PIN policy `once` and touch policy `always`. Record
both outputs:

- `age1yubikey1...`: the public recipient. Add it to `.sops.yaml` and the
  relevant creation rules, then rekey those files using an existing identity.
- `AGE-PLUGIN-YUBIKEY-1...`: the identity pointer. Set it as
  `my.sops.yubikeyIdentity` in the host's Home Manager configuration.

Home Manager writes the pointer to `identity.txt` and sets
`SOPS_AGE_KEY_FILE`. The private key stays on the YubiKey.
