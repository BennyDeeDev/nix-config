# Gaming Profile

## LSFG-VK 2.0

The gaming profile exposes an LSFG-enabled launcher for the host-selected Eden
package. The launcher enables 2x frame generation with environment variables and
preserves the existing Vulkan implicit-layer search paths.

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
