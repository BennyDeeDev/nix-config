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
