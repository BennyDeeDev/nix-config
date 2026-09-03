{ pkgs }:
{
  label = "RetroArch";
  packageName = "com.retroarch.aarch64";
  version = "1.22.2_GIT";
  versionCode = 1763607214;
  source = "https://github.com/libretro/RetroArch/releases/tag/v1.22.2";
  apk = pkgs.fetchurl {
    url = "https://buildbot.libretro.com/stable/1.22.2/android/RetroArch_aarch64.apk";
    hash = "sha256-e9XSCN/pPMji6mwEYIlIzhoEWYDxYKWMotCZOqIK0hM=";
  };
}
