{
  nixos = {
    programs = {
      zsh.enable = true;
      git.enable = true;
      vim = {
        enable = true;
        defaultEditor = true;
      };
    };
  };
}
