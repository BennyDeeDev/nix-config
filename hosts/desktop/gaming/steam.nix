{
  nixos =
    { pkgs, ... }:
    {
      programs.steam = {
        enable = true;
        remotePlay.openFirewall = true;
        dedicatedServer.openFirewall = true;
        localNetworkGameTransfers.openFirewall = true;
        gamescopeSession = {
          enable = true;
          args = [
            "--mangoapp"
            "--mouse-sensitivity=0.5"
          ];
          steamArgs = [
            "-steamdeck"
            "-steamos3"
          ];
        };
        extraPackages = [
          (pkgs.writeShellScriptBin "steamos-session-select" "steam -shutdown")
          (pkgs.writeShellScriptBin "steamos-update" "exit 7")
          (pkgs.writeShellScriptBin "steamos-select-branch" ''echo "Not applicable for this OS"'')
          (pkgs.writeShellScriptBin "jupiter-biosupdate" ''echo "No updates configured for this bios"; exit 0'')
        ];
      };
    };
}
