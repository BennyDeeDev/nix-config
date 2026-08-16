{
  nixos =
    { pkgs, config, ... }:
    {
      sops.secrets."benjamin-password" = {
        sopsFile = ../../secrets/common.yaml;
        neededForUsers = true;
      };

      users.users.benjamin = {
        isNormalUser = true;
        shell = pkgs.zsh;
        extraGroups = [ "wheel" ];
        hashedPasswordFile = config.sops.secrets."benjamin-password".path;
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHW2qr7cup1ALuIpnhUoJP8dLjv/yhGfuh/1Vni2lSbd"
        ];
      };
    };
}
