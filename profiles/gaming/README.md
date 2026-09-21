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
