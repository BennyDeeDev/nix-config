# MacBook bootstrap

The `mbp-personal` configuration targets Apple Silicon and the macOS user
`benjaminderksen`. It combines nix-darwin, Home Manager, and Homebrew.

## Bootstrap

### 1. Install Nix

```bash
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
```

Open a new terminal after installation.

```bash
export NIX_CONFIG='extra-experimental-features = nix-command flakes'
```

### 2. Clone the repository

```bash
mkdir -p ~/Repos
nix run nixpkgs#git -- clone https://github.com/BennyDeeDev/nix-config ~/Repos/nix-config
cd ~/Repos/nix-config
```

The configured rebuild aliases use this checkout path.

### 3. Install Homebrew

If Homebrew is not installed, run its installer:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the installer's shell setup instructions. Sign in to the App Store
with the account that owns the configured apps, Xcode and Final Cut Pro.

### 4. Grant Terminal permissions

Run the first switch from Terminal.app. In **System Settings → Privacy &
Security**, enable these permissions for Terminal.app:

- **Full Disk Access**, for the `universalaccess` defaults.
- **App Management**, for Home Manager's application copies under
  `~/Applications/Home Manager Apps`.

Quit and reopen Terminal.app after changing permissions.

### 5. Apply the configuration

The flake tracks nix-darwin's `master` branch. Use the matching bootstrap
launcher:

```bash
sudo nix --extra-experimental-features 'nix-command flakes' \
  run github:nix-darwin/nix-darwin/master#darwin-rebuild -- \
  switch --flake ~/Repos/nix-config#mbp-personal
```

If activation reports conflicting files under `/etc`, follow
[Unexpected files in /etc](#unexpected-files-in-etc), then retry.

### 6. Enable Hammerspoon

Open Hammerspoon, grant it **Accessibility** permission under **System
Settings → Privacy & Security → Accessibility**, and enable **Launch at
Login** in its preferences.

The profile manages `~/.hammerspoon/init.lua`. Hammerspoon supplies directional
focus, the custom window layout, and application launchers; macOS handles the
native tiling and desktop shortcuts.

## Rebuild

After bootstrap, `darwin-rebuild` is installed:

```bash
sudo darwin-rebuild switch --flake ~/Repos/nix-config#mbp-personal
```

## Shortcuts

**Hyper** means **Control + Option + Command** on macOS and
**Control + Alt + Meta** on KDE.

| Shortcut | KDE | macOS |
| --- | --- | --- |
| Hyper + H/J/K/L | Focus window west/south/north/east | Focus nearest window west/south/north/east |
| Hyper + Shift + H/J/K/L | Tile left/bottom/top/right | Native tile left/bottom/top/right |
| Hyper + M | Maximize | Native Fill |
| Hyper + C | — | Native Center |
| Hyper + R | — | Native Return to Previous Size |
| Hyper + W | Overview | Mission Control |
| Hyper + D | Show Desktop | Show Desktop |
| Hyper + G | Edit Tiles | Center active window at 80% width, full height |
| Hyper + T | Launch Konsole | Open a new Terminal.app window |
| Hyper + F | Launch Dolphin | Open a new Finder window |
| Hyper + P | Launch KeePassXC | Launch KeePassXC |
| Hyper + , | Launch System Settings | Launch System Settings |
| Hyper + S | Launch System Monitor | Launch Activity Monitor |

Apple's Fn + Control window shortcuts remain available.

## Troubleshooting

### Unexpected files in /etc

nix-darwin will not overwrite unmanaged files. Back up only the paths named
in its error. For example:

```bash
sudo mv /etc/nix/nix.conf /etc/nix/nix.conf.before-nix-darwin
sudo mv /etc/bashrc /etc/bashrc.before-nix-darwin
sudo mv /etc/zprofile /etc/zprofile.before-nix-darwin
sudo mv /etc/zshrc /etc/zshrc.before-nix-darwin
```

Then rerun the switch command.

### Home Manager app-copy failures

If `rsync` hangs or reports `Permission denied` under
`~/Applications/Home Manager Apps`, quit the copied applications first.
A failed App Management probe can leave root-owned bundle files.

After checking the Terminal permissions above, remove the Home Manager app
copies and retry the rebuild:

```bash
sudo /bin/rm -rf "$HOME/Applications/Home Manager Apps"
```

Home Manager recreates these copies during activation. Apps in `/Applications`
and the Nix store are unaffected.
