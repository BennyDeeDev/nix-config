{
  homeManager =
    { lib, pkgs, ... }:
    {
      home.packages = lib.optionals pkgs.stdenv.isLinux (
        with pkgs;
        [
          aseprite
          dotnet-sdk
          godot-mono
          lldb
        ]
      );
    };
}
