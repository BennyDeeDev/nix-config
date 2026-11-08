# Pi 5 DMZ host

`pi5-dmz` boots entirely from NVMe. Flash the separate NVMe bootstrap image,
boot without a microSD card, enroll the Pi's age key, then deploy the host with
`nixos-rebuild`. The existing SD bootstrap and other Pi hosts are unchanged.

## Boot chain

The image uses nixpkgs' generic AArch64 image builder with the mainline kernel
and a patched U-Boot 2026.10. U-Boot already includes the NVMe DMA translation
change; the [U-Boot overlay](../../overlays/uboot-rpi-arm64.nix) adds the
remaining DMA traversal and Pi NVMe enablement patches and selects NVMe before
SD. The Pi profile enables this overlay only for NVMe boot.

The builder creates the complete MBR disk image: a 512 MiB FAT partition
labelled `FIRMWARE`, and an ext4 root labelled `NIXOS_NVME`. Pi firmware,
patched U-Boot, and `config.txt` are included at image-build time; extlinux,
the kernel, and initrd live under `/boot` on the root filesystem. The root
partition expands on first boot.

Both the image and deployed host set `my.pi.bootMedium = "nvme"` in the Pi
profile; existing hosts default to `"sd"`. No Disko,
`nixos-hardware`, manual firmware copy, or bootloader wrapper is required.
Normal rebuilds update the kernel, initrd, and boot generations, but leave Pi
firmware, U-Boot, and `config.txt` as flashed. Reflashing destroys the existing
installation; do not use it as a routine update procedure.

## Build and flash

Run from the repository root with the new files added to Git:

```bash
nix build .#images.pi-nvme-bootstrap
nix run nixpkgs#zstd -- -d result/sd-image/*.img.zst -o pi-nvme-bootstrap.img
```

The build machine needs AArch64 support, either native, emulated, or through a
remote builder. Connect the NVMe through a USB enclosure or use an existing SD
installation to flash it. Identify the whole target disk with `lsblk`, unmount
its partitions, and replace `/dev/sdX` below. **This erases that entire disk**;
do not select the build machine's system disk or a partition:

```bash
sudo dd if=pi-nvme-bootstrap.img of=/dev/sdX bs=4M status=progress conv=fsync
sync
```

## Configure EEPROM and boot

Before the first NVMe boot, configure the Pi EEPROM using a working SD
installation or Raspberry Pi OS. `BOOT_ORDER=0xf16` tries NVMe, then SD, then
repeats. A non-HAT+ PCIe adapter may also need `PCIE_PROBE=1`; the image already
adds `dtparam=pciex1` to `config.txt`. See the
[Raspberry Pi PCIe documentation][pcie] for the EEPROM procedure.

Attach the NVMe to the Pi and boot with Ethernet connected and the microSD card
removed. Find the DHCP lease and SSH to the bootstrap hostname `pi`:

```bash
ssh benjamin@pi.fritz.box
```

The bootstrap allows passwordless sudo. Its age key is generated on first
boot; secret decryption can fail until enrollment, but SSH uses the authorized
key from the Pi profile. Verify `findmnt /`, `lsblk -f`, and Ethernet before
deploying. The firmware filesystem is intentionally not automatically mounted,
matching the upstream image.

## Enroll and deploy

On the Pi, print only its public age key:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  shell nixpkgs#age --command age-keygen -y /var/lib/sops-nix/key.txt
```

On the editing machine, add that public key as `&pi5-dmz` under `keys` in
`.sops.yaml` and add `*pi5-dmz` to the `secrets/shared.yaml` rule. With an
enrolled YubiKey, rekey the shared file:

```bash
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/identity.txt"
nix run nixpkgs#sops -- updatekeys secrets/shared.yaml
```

Keep the recipient-rule and encrypted metadata changes together. From the
updated checkout on the build machine, deploy onto the existing NVMe root:

```bash
nixos-rebuild switch --flake .#pi5-dmz \
  --target-host benjamin@pi.fritz.box \
  --build-host benjamin@pi.fritz.box \
  --sudo
```

This is a normal rebuild, not an installation or repartitioning operation. It
preserves the age key and other state. The host becomes `pi5-dmz` and requires
the user's password for sudo. For later rebuilds:

```bash
nixos-rebuild switch --flake .#pi5-dmz \
  --target-host benjamin@pi5-dmz.fritz.box \
  --build-host benjamin@pi5-dmz.fritz.box \
  --sudo --ask-sudo-password
```

Reboot with the SD removed and verify NVMe root, Ethernet, and boot-generation
selection. The patched U-Boot build has been validated, but the full image and
mainline-kernel/device-tree combination still need testing on the target Pi.

[pcie]: https://www.raspberrypi.com/documentation/computers/raspberry-pi.html#boot-from-pcie
