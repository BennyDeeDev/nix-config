{
  nixos = {
    my.beszel.agent = {
      enable = true;
      hubUrl = "https://stats.benjaminderksen.com";
      tokenSopsFile = ../../secrets/pi3-kiosk.yaml;
    };
  };
}
