{
  homeManager =
    {
      lib,
      pkgs,
      ...
    }:
    {
      programs.brave.enable = true;

      xdg.mimeApps = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        enable = true;
        defaultApplications = {
          "text/html" = "brave-browser.desktop";
          "x-scheme-handler/http" = "brave-browser.desktop";
          "x-scheme-handler/https" = "brave-browser.desktop";
        };
      };
    };
}
