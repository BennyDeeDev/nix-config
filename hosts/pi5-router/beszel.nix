{
  nixos = {
    my.beszel.agent = {
      enable = true;
      hubUrl = "https://stats.benjaminderksen.com";
      tokenSopsFile = ../../secrets/pi5-router.yaml;
    };
  };
}
