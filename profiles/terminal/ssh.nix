{
  homeManager =
    { ... }:
    {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
      };
    };
}
