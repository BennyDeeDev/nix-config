{ pkgs }:
{
  label = "SmartTube";
  packageName = "org.smarttube.stable";
  version = "32.10";
  versionCode = 2400;
  source = "https://github.com/yuliskov/SmartTube/releases/tag/32.10s";
  apk = pkgs.fetchurl {
    url = "https://github.com/yuliskov/SmartTube/releases/download/32.10s/SmartTube_stable_32.10_arm64-v8a.apk";
    hash = "sha256-r2BITOZeN9iD4qglsS5Zuao1iotKnLVkJ7A/DYoIJx0=";
  };
}
