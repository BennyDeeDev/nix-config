# Steam Deck Home Manager

## Reinstall or bootstrap

Run these steps after a fresh SteamOS installation.

### 1. Set the password

```bash
passwd
```

### 2. Install Nix

```bash
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh -s -- --daemon
```

Open a new shell after the installer finishes.

### 3. Enter the bootstrap shell

Set the experimental features once and load the tools needed for bootstrap:

```bash
export NIX_CONFIG='experimental-features = nix-command flakes'
nix shell nixpkgs#gh nixpkgs#git nixpkgs#age nixpkgs#sops nixpkgs#age-plugin-yubikey
```

Keep this shell open through the following steps.

### 4. Clone the repository

Authenticate GitHub:

```bash
gh auth login
```

Then clone the repository:

```bash
mkdir -p ~/Repos
gh repo clone BennyDeeDev/nix-config ~/Repos/nix-config
cd ~/Repos/nix-config
```

### 5. Generate the host age key

Home Manager uses this key for unattended decryption. Generate it before the
first activation.

Generate the key and print its public key:

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

Add the printed `age1...` key as the `&deck` recipient in `.sops.yaml`.

### 6. Install the YubiKey reader driver

Install `ccid` before rekeying the encrypted files.

```bash
sudo steamos-readonly disable
sudo pacman-key --init
sudo pacman-key --populate archlinux holo
sudo pacman -S --needed ccid
sudo steamos-readonly enable
sudo systemctl enable --now pcscd.socket
sudo systemctl restart pcscd.service
```

Verify that the reader is available:

```bash
age-plugin-yubikey --list-all
```

### 7. Enroll the host key in SOPS

Use the hardcoded YubiKey age identity for this command. Do not use the new
host key here.

```bash
export SOPS_AGE_KEY='AGE-PLUGIN-YUBIKEY-17Z2J5Q5Z709P64S7VFQZT'
```

Update the encrypted files separately:

```bash
sops updatekeys secrets/common.yaml
```

```bash
sops updatekeys secrets/desktop.yaml
```

Do not activate Home Manager from the rekey shell. Start a new shell, or
clear the YubiKey identity first:

```bash
unset SOPS_AGE_KEY
```

### 8. First activation

From the checkout on the Steam Deck:

```bash
cd ~/Repos/nix-config

nix run github:nix-community/home-manager -- switch -b hm-backup --flake '.#deck'
```

After activation, use the generated `hms` alias.

### 9. Set up the Nix GPU libraries

```bash
sudo /nix/store/<store-hash>-non-nixos-gpu/bin/non-nixos-gpu-setup
```

### 10. Set Zsh as the login shell

```bash
chsh -s /bin/zsh
```

# Technical Considerations

## Nix shell profile

Standalone Home Manager on SteamOS does not automatically add the system Nix
profile to `PATH`, and SteamOS updates may remove the global profile hook.
`hosts/deck/host.nix` therefore adds `/nix/var/nix/profiles/default/bin`
through `home.sessionPath`, so new shells can find `nix` while the daemon
continues to run through socket activation.

## YubiKey age support

SteamOS includes PC/SC but not the optional CCID reader driver. The `ccid`
package is installed outside Home Manager and may need to be reinstalled after
a SteamOS image update.

## Plasma session restore

KDE session restore is enabled. On Wayland, applications may restore without
their previous virtual desktop, size, or position because support depends on
KWin and each application. See KDE's [Wayland session restore notes](https://blogs.kde.org/2025/04/12/this-week-in-plasma-the-beginnings-of-wayland-session-restore/),
[known issues](https://community.kde.org/Plasma/Wayland_Known_Significant_Issues),
and [bug 421870](https://bugs.kde.org/show_bug.cgi?id=421870)

## Default shell

Home Manager installs and configures Zsh, but standalone Home Manager does not
change SteamOS's login shell. Set Zsh as the `deck` user's login shell once:

```bash
chsh -s /bin/zsh
```

Log out and back in afterward. Verify the result with:

```bash
getent passwd deck
printf '%s\n' "$SHELL"
```

Use `/bin/zsh` rather than `/home/deck/.nix-profile/bin/zsh` as the login shell;
the Nix profile path changes between Home Manager generations.

## ZSA/Oryx

SteamOS already grants the active desktop user access to USB and `hidraw`
devices through its generic `uaccess` udev rules. This is sufficient for Oryx
web flashing and live training with ZSA keyboards.

The relevant default rule is `/usr/lib/udev/rules.d/70-steam-jupiter-input.rules`:

```udev
# USB devices and topological children
SUBSYSTEMS=="usb", TAG+="uaccess"

# HID devices over hidraw
KERNEL=="hidraw*", TAG+="uaccess"
```

`systemd-logind` uses the `uaccess` tag to grant the active desktop user
temporary access to the device. This is why the ZSA `50-zsa.rules` file and
the `plugdev` group are not needed on SteamOS.

## Nix GPU setup

The Deck keeps SteamOS and its native kernel/GPU drivers. Nix graphical
applications such as Ghostty still need Nix-compatible OpenGL and Vulkan
libraries, because Nixpkgs expects them at `/run/opengl-driver`.

After Home Manager reports that the non-NixOS GPU setup is missing, run the
setup script once as root:

```bash
sudo "$(readlink -f "$(command -v non-nixos-gpu-setup)")"
```

This does not replace the SteamOS drivers. It adds a Nix userspace GPU library
environment and creates:

- `/etc/tmpfiles.d/non-nixos-gpu.conf`, which recreates the link at boot
- `/run/opengl-driver`, pointing at the Nix GPU libraries
- `/nix/var/nix/gcroots/non-nixos-gpu.conf`, keeping the setup alive through GC

Run the setup again when Home Manager reports that the Nix GPU drivers changed.

To remove the integration:

```bash
sudo rm /run/opengl-driver
sudo rm /etc/tmpfiles.d/non-nixos-gpu.conf
sudo rm /nix/var/nix/gcroots/non-nixos-gpu.conf
```

## Apple Studio Display

The 2022 Apple Studio Display works with the Steam Deck, but native
`5120x2880@60` currently black-screens on SteamOS.

### Desktop Mode

Disconnect the display, run:

```bash
sleep 30 && kscreen-doctor output.DP-1.mode.2560x1440@60
```

Then immediately reconnect the Studio Display.

### Gaming Mode

Gamescope stores the selected mode per external display in:

```text
~/.config/gamescope/modes.cfg
```

Set the Studio Display to:

```text
Apple Computer Inc StudioDisplay:2560x1440@60 0
```

For example:

```bash
sed -i 's/Apple Computer Inc StudioDisplay:.*/Apple Computer Inc StudioDisplay:2560x1440@60 0/' \
  ~/.config/gamescope/modes.cfg
```

This only changes the Studio Display. The Deck's internal `1280x800` display
remains unchanged.

### Native 5K

Native `5120x2880@60` is broken on SteamOS 3.8 with the Linux 6.16
Neptune kernel, where the Studio Display black-screens even though KDE accepts
the mode.

On SteamOS 3.9 Preview with Valve's Linux 7.2 Neptune kernel, native 5K works.
The working link uses:

```text
4 lanes × HBR2
10 bpc
DSC enabled
5120x2880@60
```

## After SteamOS updates

A SteamOS update may break the Nix integration even though the Nix store and
Home Manager configuration survive.

SteamOS keeps `/nix` on persistent storage, but `/nix` is mounted after systemd
initially scans its unit files. The Nix daemon units are symlinks into `/nix`,
so systemd can miss them during boot.

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now nix-daemon.socket
```

`daemon-reload` makes systemd rescan the Nix units after `/nix` is mounted.
`enable --now` enables socket activation for future boots and starts it now.

If the shell reports `nix: command not found`, restore the Nix profile hook in
the current shell:

```bash
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
```

Verify the shell and daemon before running Nix operations:

```bash
nix --version
nix store ping --store daemon
```
