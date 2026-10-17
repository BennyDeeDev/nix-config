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

Both YubiKeys, `yk-5-nfc` and `yk-5c-nano`, are recipients of all three secret
files. Hosts receive access through the matching rules in `.sops.yaml`.

## Edit a secret

Plug in the YubiKey selected by your Home Manager configuration:

```bash
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/identity.txt"

nix run nixpkgs#sops -- secrets/common.yaml
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
nix run nixpkgs#sops -- unset secrets/common.yaml '["obsolete-key"]'
```

For nested keys, use a path such as `'["services"]["example"]["password"]'`.
Remove the corresponding Nix declaration and consumers, then commit the changes.

## Enroll a host

### 1. Obtain the host public key

For an existing NixOS system key:

```bash
sudo nix shell nixpkgs#age --command age-keygen -y /var/lib/sops-nix/key.txt
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

sudo nix shell nixpkgs#age --command age-keygen -o /var/lib/sops-nix/key.txt
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
  - path_regex: secrets/common\.ya?ml$
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
nix run nixpkgs#sops -- updatekeys secrets/common.yaml
nix run nixpkgs#sops -- updatekeys secrets/desktop.yaml
```

For a Pi server key, update `common.yaml` and `pi5-server.yaml` instead.
Commit `.sops.yaml` and the affected encrypted files together.

### 4. Activate again

Deploy the updated checkout and rebuild the host using its setup guide.
Activation decrypts secrets with the enrolled host key; it does not require
the YubiKey.

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
