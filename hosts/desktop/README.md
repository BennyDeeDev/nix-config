# Desktop NixOS Install

Installs NixOS on the Samsung SSD 990 PRO with Heatsink (serial
`S7HFNJ0Y704719Z`) with a Btrfs layout matching the previous Arch setup.

## Partition layout

| Partition | Size      | Filesystem | Mount   |
| --------- | --------- | ---------- | ------- |
| ESP       | 1G        | vfat       | `/boot` |
| root      | remainder | btrfs      | —       |

Btrfs subvolumes: `/rootfs` → `/`, `/home` → `/home`, `/log` → `/var/log`,
`/nix` → `/nix`

## Install steps

Boot from the NixOS graphical ISO (F11 on MSI boards for the boot menu).

**1. Open a terminal and clone dotfiles**

```bash
nix-shell -p git
git clone https://github.com/BennyDeeDev/dotfiles /tmp/dotfiles
```

**2. Partition, format, and mount with disko**

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- \
  --mode destroy,format,mount /tmp/dotfiles/nix/hosts/desktop/disko.nix
```

**3. Generate hardware configuration**

```bash
sudo nixos-generate-config --no-filesystems --root /mnt
sudo cp /mnt/etc/nixos/hardware-configuration.nix /tmp/dotfiles/nix/hosts/desktop/
```

**4. Set `neededForBoot` on `/var/log`**

Open the copied `hardware-configuration.nix` and add `neededForBoot = true;` to
the `/var/log` filesystem entry:

```nix
fileSystems."/var/log" = {
  # ... existing generated content ...
  neededForBoot = true;
};
```

This ensures `/var/log` is mounted before the systemd journal starts, so no
early boot logs are lost.

**5. Set password**

```bash
sudo mkdir -p /mnt/etc/nixos
echo -n "yourpassword" | mkpasswd -m sha-512 -s | sudo tee /mnt/etc/nixos/password-hash
```

**5a. Set NAS credentials**

```bash
sudo tee /mnt/etc/nixos/smb-secrets <<EOF
username=Benjamin
password=YOUR_NAS_PASSWORD
domain=WORKGROUP
EOF
sudo chmod 600 /mnt/etc/nixos/smb-secrets
```

**6. Install**

```bash
sudo nixos-install --flake /tmp/dotfiles/nix#desktop --root /mnt
```

**7. Reboot**

```bash
sudo reboot
```

After first boot, commit the generated `hardware-configuration.nix` to the repo.

## Identifying the correct drive

Use the serial number `S7HFNJ0Y704719Z` to confirm the drive in case NVMe
enumeration order changes:

```bash
lsblk -o NAME,SIZE,SERIAL
```

## Secure Boot (Lanzaboote)

Signs all boot artifacts and enforces Secure Boot via the lanzaboote module configured in `nix/hosts/desktop/default.nix`. Keys auto-generate at `/var/lib/sbctl` and auto-enroll alongside Microsoft's UEFI CA on the first Setup-Mode boot. The steps below are the manual BIOS flow required on MSI boards to actually flip Secure Boot on.

**1. Rebuild and install the signed bootloader**

```bash
cd ~/Repos/dotfiles
sudo nixos-rebuild boot --install-bootloader --flake .#desktop
```

Must use `--install-bootloader`: the signed UKIs and `systemd-bootx64.efi` are
written to the ESP only by `bootctl install`. A plain `switch` leaves the old
unsigned binary on the ESP, which bricks on `Maximum Security` once Secure Boot
is on.

Verify before rebooting:

```bash
sudo sbctl verify
```

All `nixos-generation-*.efi`, `BOOTX64.EFI`, and `systemd-bootx64.efi` must
show ✓. The `kernel-*.efi` entries are expected to show ✗ — they are
intermediate images never loaded by firmware.

**2. Reboot and enter the BIOS (spam `Del`)**

Switch to Advanced mode (`F7`), then:

1. **Security → Secure Boot**: set `Secure Boot` = `[Enabled]`, `Secure Boot
   Mode` = `[Custom]`, `Secure Boot Preset` = `[Maximum Security]`.
2. **Security → Secure Boot → Key Management**: set `Provision Factory Default
   keys` = `[Disabled]`. Save and exit (`F10`).
3. Re-enter the BIOS before the OS boots.
4. **Security → Secure Boot → Key Management**: click `Delete all Secure Boot
   variables`. Confirm both prompts (delete, then reset without saving).

**3. Verify Secure Boot is enforced**

```bash
sudo sbctl status
sudo sbctl verify
bootctl status
```

Expected: `Secure Boot: Enabled`, `Setup Mode: Disabled`, `Vendor Keys:
microsoft builtin-db builtin-KEK builtin-PK` (your keys enrolled alongside
Microsoft's).
