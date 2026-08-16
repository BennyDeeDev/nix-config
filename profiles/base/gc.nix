{
  nixos = {
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  darwin = {
    nix.gc = {
      automatic = true;
      interval = {
        Weekday = 1;
        Hour = 0;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
  };
}
