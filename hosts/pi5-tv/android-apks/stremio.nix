{ pkgs }:
{
  label = "Stremio";
  packageName = "com.stremio.one";
  version = "1.10.4";
  versionCode = 33145732;
  source = "https://www.stremio.com/downloads";
  apk = pkgs.fetchurl {
    url = "https://dl.strem.io/android/v1.10.4-androidTV/com.stremio.one-1.10.4-33145732-arm64-v8a.apk";
    hash = "sha256-yq9Pq6QjpHwxdO2gi5QFeVbOMq9hbGN3s0hfT13smTw=";
  };
}
