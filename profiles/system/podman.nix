{
  nixos = { ... }: {
    virtualisation.podman.enable = true;
  };

  homeManager =
    { lib, pkgs, ... }:
    {
      # macOS needs the client package because NixOS provides it with the runtime.
      home.packages = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ pkgs.podman ];
      programs.zsh.shellAliases.d = "podman";
    };
}
