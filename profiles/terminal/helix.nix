{ helixFlake }:
{
  homeManager =
    { pkgs, ... }:
    {
      programs.helix = {
        enable = true;
        package = helixFlake.packages.${pkgs.stdenv.hostPlatform.system}.default;

        settings = {
          theme = {
            dark = "catppuccin_mocha";
            light = "catppuccin_latte";
          };

          editor = {
            gutters.line-numbers.min-width = 60;
            scrolloff = 20;
          };
        };

        languages.language = [
          {
            name = "nix";
            formatter.command = "nixfmt";
            auto-format = true;
          }
          {
            name = "markdown";
            formatter = {
              command = "rumdl";
              args = [
                "fmt"
                "--silent"
                "-"
              ];
            };
            auto-format = true;
          }
          {
            name = "bash";
            formatter = {
              command = "shfmt";
              args = [
                "--filename"
                "%{buffer_name}"
              ];
            };
            auto-format = true;
          }
          {
            name = "javascript";
            formatter = {
              command = "prettier";
              args = [
                "--stdin-filepath"
                "%{buffer_name}"
              ];
            };
            auto-format = true;
          }
          {
            name = "jsx";
            formatter = {
              command = "prettier";
              args = [
                "--stdin-filepath"
                "%{buffer_name}"
              ];
            };
            auto-format = true;
          }
          {
            name = "typescript";
            formatter = {
              command = "prettier";
              args = [
                "--stdin-filepath"
                "%{buffer_name}"
              ];
            };
            auto-format = true;
          }
          {
            name = "tsx";
            formatter = {
              command = "prettier";
              args = [
                "--stdin-filepath"
                "%{buffer_name}"
              ];
            };
            auto-format = true;
          }
          {
            name = "python";
            formatter = {
              command = "ruff";
              args = [
                "format"
                "--stdin-filename"
                "%{buffer_name}"
                "-"
              ];
            };
            auto-format = true;
          }
          {
            name = "toml";
            formatter = {
              command = "taplo";
              args = [
                "fmt"
                "-"
              ];
            };
            auto-format = true;
          }
          {
            name = "yaml";
            formatter = {
              command = "yamlfmt";
              args = [ "-" ];
            };
            auto-format = true;
          }
          {
            name = "github-action";
            formatter = {
              command = "yamlfmt";
              args = [ "-" ];
            };
            auto-format = true;
          }
        ];

      };
    };
}
