# Remove once the locked U-Boot supports Pi 5 NVMe boot without these changes:
# DMA parent traversal, Pi NVMe enablement, and an NVMe boot target.
# Remaining patches from Torsten Duwe's "Fix NVMe, not only on Raspberry Pi 5" v2:
# https://lists.denx.de/pipermail/u-boot/2026-July/624063.html
# U-Boot 2026.10 contains patch 3/4; patch 2/4 is a test-only change.
final: prev: {
  ubootRaspberryPiAarch64 =
    let
      fetchLorePatch =
        {
          name,
          msgId,
          hash,
        }:
        final.fetchurl {
          inherit name hash;
          url = "https://lore.kernel.org/u-boot/${msgId}@verein.lst.de/raw";
          # lore rejects curl's default User-Agent.
          curlOptsList = [
            "-A"
            "git/2.40"
          ];
        };

      rpi5NvmePatches = [
        (fetchLorePatch {
          name = "0001-core-skip-parent-nodes-without-dt.patch";
          msgId = "20260706172147.C934268B05";
          hash = "sha256-Yp/3vVmrVNa4Y5Z4/W4KEu6c7+clIKNiAf92BTsanVA=";
        })
        (fetchLorePatch {
          name = "0004-rpi-enable-nvme.patch";
          msgId = "20260706172154.B506B68CFE";
          hash = "sha256-G6Tp0yGK+rBztOzFe6iMKjo1IjULSGXhNkz5OrHNnPk=";
        })
      ];
    in
    (prev.ubootRaspberryPiAarch64.override {
      extraPatches = rpi5NvmePatches;
    }).overrideAttrs
      (old: {
        postPatch = (old.postPatch or "") + ''
          substituteInPlace board/raspberrypi/rpi/rpi.env \
            --replace-fail "boot_targets=mmc usb pxe dhcp" \
            "boot_targets=nvme mmc usb pxe dhcp"
        '';
      });
}
