{ ... }:

{
  homeManager =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        liberation_ttf
        wqy_zenhei
      ];
    };
}
