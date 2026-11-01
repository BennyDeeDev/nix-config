{
  nixos = {
    networking.hostName = "pi5-server";
    networking.firewall.enable = false;
    boot.loader = {
      generic-extlinux-compatible.enable = true;
      grub.enable = false;
    };
    sops.secrets = {
      "smb-username".sopsFile = ../../secrets/pi5-server.yaml;
      "smb-password".sopsFile = ../../secrets/pi5-server.yaml;
      "restic-repo-password".sopsFile = ../../secrets/pi5-server.yaml;
      "cloudflare-api-token".sopsFile = ../../secrets/pi5-server.yaml;
      "ntfy-topic".sopsFile = ../../secrets/pi5-server.yaml;
      "gatus-external-token".sopsFile = ../../secrets/pi5-server.yaml;
      "caddy-basic-auth-hash".sopsFile = ../../secrets/pi5-server.yaml;
    };

    my.nas.shares = [
      "Homelab"
      "Restic"
    ];
  };
}
