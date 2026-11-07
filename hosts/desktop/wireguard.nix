let
  wireguardModule = import ../../modules/wireguard.nix;
in
{
  nixos = {
    imports = [ wireguardModule.nixos ];

    sops.secrets."wireguard-private-key".sopsFile = ../../secrets/desktop.yaml;
    networking.wireguard.interfaces.wg0.ips = [ "10.77.30.2/32" ];
  };
}
