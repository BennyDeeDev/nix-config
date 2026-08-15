{
  my.sops.smartcard.enable = true;

  sops = {
    defaultSopsFile = ../../secrets/desktop.yaml;
    secrets."benjamin-password" = {
      sopsFile = ../../secrets/common.yaml;
      neededForUsers = true;
    };
  };
}
