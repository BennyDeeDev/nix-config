{
  homeManager =
    {
      pkgs,
      ...
    }:
    {
      programs.vscode = {
        enable = true;
        mutableExtensionsDir = false;
        package = pkgs.vscode;
        profiles.default.extensions = with pkgs.vscode-extensions; [
          github.copilot-chat
          catppuccin.catppuccin-vsc
          catppuccin.catppuccin-vsc-icons
          esbenp.prettier-vscode
          jnoortheen.nix-ide
        ];
      };
    };
}
