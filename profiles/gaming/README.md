# Gaming

The gaming profile configures Steam, Steamdex, Flatpak applications, portable
Bottles, LSFG launchers, and save backups. These instructions assume the profile
has been activated. The `lsfg-vk-*` and `steam-host` commands are supplied by
Home Manager, rather than exported as standalone flake packages.

## Steamdex

The gaming profile enables `my.steamdex` and sets the shared Steam directory
and account ID. Each host defines its parsers and apps through
`my.steamdex.settings`. Home Manager writes the configuration to
`~/.config/steamdex/config.json`; Steamdex loads it automatically, respecting
`XDG_CONFIG_HOME` when set. SOPS renders the SteamGridDB API key from
`secrets/common.yaml` to `~/.config/steamdex/secrets.json` for Steamdex.

Preview the configured shortcuts, then write them to Steam:

```bash
steamdex list
steamdex parse --preview
steamdex parse
```

Steamdex preserves existing Steam shortcuts and updates matching entries. The
first parse may add a second entry if a previous shortcut used a different
executable or title.

## LSFG-VK 2.0

### Prepare Lossless Scaling

1. Open Lossless Scaling's properties in Steam.
2. Under **Betas**, select the `lsfg-vk` branch.
3. Wait for the download to finish and check that the DLL is present:

   ```bash
   ls -l "$HOME/.local/share/Steam/steamapps/common/Lossless Scaling/lsfg-vk.dll"
   ```

The regular branch's `LosslessScaling.dll` is incompatible with LSFG-VK 2.0.

### Launch an application

Choose the frame multiplier:

```bash
lsfg-vk-2x eden-steamdeck-pgo
lsfg-vk-3x eden-steamdeck-pgo
lsfg-vk-4x eden-steamdeck-pgo
```

The launchers also accept other executables or Steam's `%command%` launch
placeholder. They enable the Vulkan layer for that command and preserve
existing implicit-layer search paths.

## Portable gaming setup

The desktop and Deck share an SD card configured through
`my.gaming.portableGamesPath`. For the terminal examples below, set:

```bash
portable="/run/media/$USER/976d3eeb-4b99-4f9b-b67c-a708c59432e7"
bottle="$portable/Bottles/gaming-portable-bottle"
```

### 1. Create the bottle

Create `gaming-portable-bottle` using the card's `Bottles` directory as the
custom Bottles location. Close Bottles before editing its `bottle.yml`:

```yaml
Custom_Path: false
Environment_Variables:
  USER: portable
Path: gaming-portable-bottle
```

Home Manager registers the bottle through a symlink:

```text
~/.var/app/com.usebottles.bottles/data/bottles/bottles/gaming-portable-bottle
-> /run/media/<user>/976d3eeb-4b99-4f9b-b67c-a708c59432e7/Bottles/gaming-portable-bottle
```

Keep the relative `Path` in the shared `bottle.yml`; do not create a
`placeholder.yml`. Reopen the bottle with:

```bash
flatpak run com.usebottles.bottles --bottle gaming-portable-bottle
```

### 2. Map the portable drive

After the bottle has initialized, map `P:` to the card before installing games:

```bash
ln -sfn -- ../../.. "$bottle/dosdevices/p:"
```

The relative target resolves to the card for both `deck` and `benjamin`.
This replaces any stale `p:` link. `p::` is a separate Wine device mapping.

### 3. Install and launch games

When a Windows installer asks for the destination, use:

```text
P:\PC\<Game Name>
```

This keeps registry paths portable. For an existing installation with
host-specific paths, update the relevant registry entries to their `P:\...`
equivalents.

Create `PC/<Game Name>/my.launcher.bat` to launch the game relative to its own
directory. For example:

```bat
"%~dp0Gameface\Binaries\Win64\Game.exe"
```

`%~dp0` is the batch file's directory. Steamdex finds these launchers and runs
them through the portable bottle. To test one manually, replace
`Game Name` with the actual directory:

```bash
launcher="$portable/PC/Game Name/my.launcher.bat"
flatpak run \
  --command=bottles-cli \
  --unshare=network \
  com.usebottles.bottles run \
  -b gaming-portable-bottle \
  -e "$launcher"
```

### 4. Configure portable Eden data

Set up Eden's firmware and keys first. Under **Emulation → Configure →
System**, set both **NAND** and **Save Data** to:

```text
/run/media/<user>/976d3eeb-4b99-4f9b-b67c-a708c59432e7/Eden/nand
```

Replace `<user>` with `deck` or `benjamin`, then restart Eden.

## Steam host launches

Steam runs non-Steam entries inside its Scout runtime. `steam-host` clears the
overlay preload and switches to the host environment before launching Flatpak
or Nix applications. Steamdex uses it in Deck app and portable game entries,
for example:

```bash
steam-host flatpak run \
  --command=bottles-cli \
  --unshare=network \
  com.usebottles.bottles run \
  -b gaming-portable-bottle \
  -e "/path/to/my.launcher.bat"

steam-host "$HOME/.nix-profile/bin/VacuumTube"
```

Replace the launcher path with the game's batch file. The Flatpak executable
is available on the configured gaming hosts.

## Duplicate Deck controllers in Bottles

Wine can expose two active XInput controllers in Steam Deck Gaming Mode,
causing duplicate menu inputs, broken D-pad navigation, or mouse interaction
issues. This was reproduced with Soda 11, with Steam Input both enabled and
disabled; Desktop Mode exposed only one responding controller.

To disable Wine's SDL controller backend while retaining XInput:

1. Open Wine's Control Panel in the affected bottle. For the portable bottle:

   ```bash
   flatpak run \
     --command=bottles-cli \
     --unshare=network \
     com.usebottles.bottles tools \
     -b gaming-portable-bottle \
     control
   ```

2. Open **Game Controllers → Advanced**, uncheck **Enable SDL**, and apply.
3. Restart the game so Wine reloads its controller configuration.
