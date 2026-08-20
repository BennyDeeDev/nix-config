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

`drs` opens Terminal.app and runs the rebuild there. Enter your `sudo` password
in the Terminal.app window when prompted.
