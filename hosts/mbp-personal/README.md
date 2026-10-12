# nix-darwin bootstrap

## 1. Install Nix

```sh
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
```

## 2. First switch

```sh
sudo nix --extra-experimental-features 'nix-command flakes' \
  run nix-darwin/nix-darwin-26.05#darwin-rebuild -- \
  switch --flake ~/Repos/nix-config#mbp-personal
```

If it fails with "Unexpected files in /etc", back them up and re-run:

```sh
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
sudo mv /etc/zprofile /etc/zprofile.before-nix-darwin
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
```

## macOS Privacy Permissions

Run `darwin-rebuild` from **Terminal.app** and enable these permissions for
Terminal.app in **System Settings → Privacy & Security**:

- **Full Disk Access**: required by the macOS `universalaccess` defaults.
- **App Management**: required by Home Manager to copy apps into
  `~/Applications/Home Manager Apps` for Spotlight and Launchpad.

Quit and reopen Terminal.app after changing permissions.

## Hammerspoon

The macOS profile installs Hammerspoon and manages `~/.hammerspoon/init.lua`.
After rebuilding, open Hammerspoon and grant it **Accessibility** permission in
**System Settings → Privacy & Security → Accessibility**. Enable **Launch at
Login** in Hammerspoon's preferences.

The global shortcuts use **Hyper** (`Control + Option + Command`). Hammerspoon
requires **Accessibility** permission for directional focus, the custom layout,
and application launchers. macOS handles the native tiling and desktop actions.

| Shortcut | KDE | macOS |
| --- | --- | --- |
| Hyper + H/J/K/L | Focus window west/south/north/east | Focus nearest window west/south/north/east (Hammerspoon) |
| Hyper + Shift + H/J/K/L | Tile left/bottom/top/right | Native tile left/bottom/top/right |
| Hyper + M | Maximize | Native Fill |
| Hyper + C | — | Native Center |
| Hyper + R | — | Native Return to Previous Size |
| Hyper + W | Overview | Mission Control |
| Hyper + D | Show Desktop | Show Desktop |
| Hyper + Shift + T | Edit Tiles | Center active window at 80% width, full height (Hammerspoon) |
| Hyper + T | Launch Ghostty | Open a new Ghostty window |
| Hyper + F | Launch Dolphin | Open a new Finder window |
| Hyper + P | Launch KeePassXC | Launch KeePassXC |
| Hyper + , | Launch System Settings | Launch System Settings |
| Hyper + S | Launch System Monitor | Launch Activity Monitor |
| Hyper + C | — | Native Center |
| Hyper + R | — | Native Return to Previous Size |

The tile, Fill, Center, and Restore actions use macOS's native symbolic hotkeys.
Mission Control and Show Desktop also use macOS symbolic hotkeys. Apple's Fn +
Control window shortcuts remain available as well. Hammerspoon requires
**Accessibility** permission for directional focus, the custom layout, and
application window creation.

If `rsync` hangs or reports `Permission denied` while removing files under
`~/Applications/Home Manager Apps`, stop the copied app before retrying. A
failed App Management probe can leave bundle files owned by `root`. Quit the
affected applications, then remove only the Home Manager app copies:

```sh
sudo /bin/rm -rf "$HOME/Applications/Home Manager Apps"
```

This removes neither `/Applications` apps nor Nix packages; Home Manager
recreates its copies after a successful activation.

## 3. Subsequent rebuilds

```sh
sudo darwin-rebuild switch --flake ~/Repos/nix-config#mbp-personal
```
