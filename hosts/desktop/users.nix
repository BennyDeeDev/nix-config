{
  nixos =
    { config, pkgs, ... }:
    {
      users.users.benjamin = {
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = [
          "networkmanager"
          "wheel"
          "libvirtd"
        ];
        hashedPasswordFile = config.sops.secrets."benjamin-password".path;
      };
    };
}
