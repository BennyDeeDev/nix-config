{ pkgs }:

{
  version = "20260106";

  images =
    pkgs.runCommand "waydroid-atv-20260106-arm64-images"
      {
        nativeBuildInputs = [ pkgs.unzip ];
      }
      ''
        install -d "$out"
        unzip -p "${
          pkgs.fetchurl {
            url = "https://github.com/WayDroid-ATV/waydroid-androidtv-builds/releases/download/20260106/lineage-20.0-20260106-VANILLA-waydroid_tv_arm64-system.zip";
            hash = "sha256-50dkAHSf/DJr5SdTW/XxWKnPyMHuXkR3iOdjKXg6YjU=";
          }
        }" system.img > "$out/system.img"
        unzip -p "${
          pkgs.fetchurl {
            url = "https://github.com/WayDroid-ATV/waydroid-androidtv-builds/releases/download/20260106/lineage-20.0-20260106-MAINLINE-waydroid_tv_arm64-vendor.zip";
            hash = "sha256-AgJ0HKt+K96z0IyGulbBmVWasxTrId1lK4taOhx/uwA=";
          }
        }" vendor.img > "$out/vendor.img"
      '';
}
