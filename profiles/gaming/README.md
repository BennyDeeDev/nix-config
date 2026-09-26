# Gaming Profile

## LSFG-VK 2.0

The gaming profile exposes generic LSFG-enabled launchers. They configure the
Vulkan layer for one command without enabling it globally, and preserve the
existing Vulkan implicit-layer search paths.

```bash
lsfg-vk-2x eden-steamdeck-pgo
lsfg-vk-3x eden-steamdeck-pgo
lsfg-vk-4x eden-steamdeck-pgo
```

The same launchers can wrap other executables or Steam's `%command%` launch
placeholder.

Before using the launcher, switch Lossless Scaling to Steam's `lsfg-vk` branch:

1. Open Lossless Scaling's Steam properties.
2. Open the **Betas** tab.
3. Select the `lsfg-vk` branch.
4. Let Steam finish downloading the branch.

The regular branch provides `LosslessScaling.dll`, which is incompatible with
LSFG-VK 2.0. The `lsfg-vk` branch must provide this file:

```bash
ls -l "$HOME/.local/share/Steam/steamapps/common/Lossless Scaling/lsfg-vk.dll"
```

## Steam Host Launches

Steam launches non-Steam entries inside its Scout runtime. The gaming profile
provides `steam-host` for Deck Steam ROM Manager entries that launch Flatpak or
Nix applications. It clears Steam's overlay preload and switches back to the
host environment before executing the command:

```bash
steam-host flatpak run --command=bottles-cli --unshare=network \
  com.usebottles.bottles run -b gaming-portable-bottle -e <launcher>

steam-host "$HOME/.nix-profile/bin/VacuumTube"
```

## Bottles Steam Deck Controller Fix

When running Windows games through Bottles Flatpak in Steam Deck Gaming Mode,
Wine may expose the Steam Deck controller as two simultaneously active XInput
controllers.

In KDE Desktop Mode, only one controller responds. In Gaming Mode, both
controllers receive the same inputs. This can cause broken menu navigation,
unresponsive D-pad controls, and mouse interaction issues, even when controller
input works correctly during gameplay.

The issue was reproduced with Soda 11 and occurs with Steam Input enabled or
disabled.

### Fix

Disable Wine's SDL controller backend to eliminate the duplicate controller
while keeping XInput functional.

Launch Wine's Control Panel inside the existing bottle:

```bash
flatpak run --command=bottles-cli --unshare=network \
  com.usebottles.bottles tools -b gaming-bottle control
```

Open **Game Controllers → Advanced**, uncheck **Enable SDL**, and apply the
changes.

Restart the game to ensure Wine initializes its controller backends with the
updated configuration.

## Game Launchers

Each PC game has a `my.launcher.bat` in its game directory:

```text
PC/<Game Name>/my.launcher.bat
```

The batch file launches the game relative to its own directory. Generic example:

```bat
"%~dp0Gameface\Binaries\Win64\Game.exe"
```

`%~dp0` means the directory containing the batch file. Steam ROM Manager finds
these files and launches them through the portable bottle:

```bash
flatpak run --command=bottles-cli --unshare=network \
  com.usebottles.bottles run \
  -b "gaming-portable-bottle" \
  -e "<path-to-my.launcher.bat>"
```

## Portable Gaming Setup

This setup keeps selected gaming data on removable storage so compatible
systems can share games, saves, and application data. Each application has its
own portable configuration.

### Portable Bottles

Create a bottle using this custom Bottles directory:

```text
/run/media/<user>/976d3eeb-4b99-4f9b-b67c-a708c59432e7/Bottles
```

Set its `bottle.yml`:

```yaml
Custom_Path: false
Environment_Variables:
  USER: portable
Path: gaming-portable-bottle
```

Home Manager registers the bottle by creating a symlink:

```text
~/.var/app/com.usebottles.bottles/data/bottles/bottles/gaming-portable-bottle
-> /run/media/<user>/976d3eeb-4b99-4f9b-b67c-a708c59432e7/Bottles/gaming-portable-bottle
```

This lets Bottles find the portable prefix while keeping the actual bottle on
the SD card. Do not use `placeholder.yml`; the shared `bottle.yml` keeps its
relative `Path`.

Start it with:

```bash
flatpak run com.usebottles.bottles --bottle "gaming-portable-bottle"
```

### Portable Game Installation

Create the portable `H:` drive mapping before installing a Windows game:

```bash
cd "/run/media/<user>/976d3eeb-4b99-4f9b-b67c-a708c59432e7/Bottles/gaming-portable-bottle/dosdevices"
ln -sfn -- ../../.. 'h:'
```

The relative target makes `H:` resolve to the SD card regardless of whether the
current user is `deck` or `benjamin`.

When an installer asks where to install the game, use a path on `H:`:

```text
H:\PC\<Game Name>
```

Some Windows installers store the installation path in the registry. Installing
to `H:` ensures those registry entries are portable from the start. If an
installer writes a host-specific path instead, update its registry entries to
use the equivalent `H:\...` path before launching the game. Replace any existing
stale `h:` link with the command above.

`h:` is the Wine directory mapping. Do not confuse it with `h::`, which is a
separate Wine device mapping.

### Portable Eden

Set Eden's firmware and keys first.

Open **Eden -> Emulation -> Configure -> System**, then set both the **NAND**
and **Save Data** paths to:

```text
/run/media/<user>/976d3eeb-4b99-4f9b-b67c-a708c59432e7/Eden/nand
```

Replace `<user>` with `deck` or `benjamin`, then restart Eden.
