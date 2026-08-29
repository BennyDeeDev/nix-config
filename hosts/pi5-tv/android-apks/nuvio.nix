{ pkgs }:
{
  label = "NuvioTV";
  packageName = "com.nuvio.tv";
  version = "0.8.11-beta";
  versionCode = 1052;
  source = "https://github.com/NuvioMedia/NuvioTV/releases/tag/0.8.11-beta";
  apk = pkgs.fetchurl {
    url = "https://github.com/NuvioMedia/NuvioTV/releases/download/0.8.11-beta/app-full-arm64-v8a-release.apk";
    hash = "sha256-j+mtFLBOcA1Q56v/fknrFGsY0p9ADPIl+JguruOpu1w=";
  };
}
